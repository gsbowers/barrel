pro barrel_pick_precip, timestamp, probe

verison = 'v05'
dhour = 6*3600.0d ;seconds

;extract start of day from epoch in seconds 
tday = gettime(time_string(timestamp, tformat='YYYY-MM-DD')) 
;extract start of hour from 00:00 in seconds
hour = gettime(time_string(timestamp, tformat='YYYY-MM-DD/hh:mm:ss'))-tday

;dataytpes to load from bdas
datatypes = "SSPC EPHM FSPC"

;set timespan
timespan, tday, 2, /day
;data to display while searching for precipitation
bkg_energy = 110
barrel_load_data, probe=probe, datatype=datatypes, version=version
barrel_make_fspc, probe
barrel_load_model_bkg, probe, bkg_energy
noaa_load_kp

;iterate through day in dhour intervals
hour_begin = hour 
hour_end = hour+dhour
tstart = tday+hour_begin
ddhour = (hour_end-hour_begin)

while 1 do begin

	reload = 0
	;set timespan
	if hour_end ge 24*3600.0d then begin
		hour_end = 0.0
		timespan, tstart, ddhour+1.0, /seconds
		reload = 1
	endif 
	if hour_begin lt 0.0d then begin
		hour_begin = 24.0*3600 - dhour 
		timespan, tstart, ddhour, /seconds
		reload = 1
	endif

	if reload then begin
		barrel_load_data, probe=probe, datatype=datatypes, version=version
		barrel_make_fspc, probe
		barrel_load_model_bkg, probe, bkg_energy
		noaa_load_kp
	endif

	timespan, tstart, ddhour, /seconds
	
	;plot data
	window, 1, ysize=800
	wset, 1
	vars = string(format='(%"brl%s_SSPC brl%s_FSPC brl%s_%0dkeV brl%s_GPS_Alt")',$
	 	probe, probe, probe, bkg_energy, probe)   
	tplot, vars

	;print probe and current timespan	
	print, string(format='(%"%s %s-%s")', probe, time_string(tstart, tformat="YYYY-MM-DD/hh:mm"), time_string(tstart+ddhour, tformat="YYYY-MM-DD/hh:mm"))

	;read command from keyboard
	flag = 0
	Repeat begin

		;prompt
		print, 'Please enter a command:'
		print, 'c: continue; reset window & advance tstart'
		print, 'a: advance end of window'
		print, 'r: rollback beginning of window'
		print, 't: use tlimit (stopped)'
		print, 's: spectroscopy'
		input = get_kbrd(/escape)

		case input of
			'c': begin 
					;extract start of day from epoch in seconds 
					tstart += ddhour ;advance window start
					tday = gettime(time_string(tstart, tformat='YYYY-MM-DD'))
					;extract start of hour from 00:00 in seconds
					hour = gettime(time_string(tstart, tformat='YYYY-MM-DD/hh:mm:ss'))-tday
					hour_begin = hour
					hour_end = hour+dhour
					ddhour = dhour ;reset window 
					flag = 1 ;continue		
				end
			'a': begin
					hour_end += dhour ;advance hour of day
					ddhour += dhour 
					flag = 1 ;continue
				end
			'r': begin
					tstart -= ddhour ;rollback window start
					hour_begin -= ddhour ;rollback hour of day
					ddhour += dhour ;add time to window
					flag = 1 ;continue
				end
			't': begin 
					print, 'use tlimit. do ".c" to continue'
					;trange = timerange(/current) ;timerange of current display
					stop
				end
			's': begin
					trange = timerange(/current) ;timerange of current display
					date = time_string(trange[0], tformat='YYYY-MM-DD/hh:mm:ss')
					hours = (trange[1]-trange[0])/3600.0d 
					
					fitrange=[80.,2500.]
					print, 'calling spectroscopy routine'
					barrel_spectroscopy, specstruct, date,hours, probe, /slow, $
						systematic_error_frac=0.1, fitrange=fitrange, numbkg=2, $
						/bkgrenorm

					;calculate ss.moduals/ss.bkgspec and stop fit where 
					;model is < 5% of background
					new_fitrange = barrel_check_sp_fitrange(specstruct,threshold=0.05)
					print, 'stopped' 
					print, string(format='(%"old fitrange=[%g,%g]")', fitrange)
					print, string(format='(%"new fitrange=[%g,%g]")', new_fitrange)
					print, '>>>set "sp_flag" to 1 to redo fit'
					print, '>>>do ".c" to continue'
					sp_flag = 0

					stop

					while sp_flag do begin 
						fitrange= new_fitrange
						print, 'redoing spectroscopy'
						barrel_spectroscopy, specstruct, date,hours, probe, /slow, $
							systematic_error_frac=0.1, fitrange=fitrange, numbkg=2,$ 
							starttimes = specstruct.trange[0], $
							endtimes = specstruct.trange[1], $
							startbkgs = reform(specstruct.bkgtrange[0,*]), $
							endbkgs = reform(specstruct.bkgtrange[1,*]), $	
							/bkgrenorm

						sp_flag = 0

					endwhile

					;reset color table and window
					thm_graphics_config
					wset, 1

					;save spectral structure in named save file
					ss_savname = string(format='(%"brl%s_%s_%06d_spectra.sav")', $
						probe, $
						time_string(specstruct.trange[0], tformat='yyMMDD_hhmmss'), $
						specstruct.trange[1]-specstruct.trange[0])

					ps_savname = string(format='(%"brl%s_%s_%06d_precip.sav")', $
						probe, $
						time_string(specstruct.trange[0], tformat='yyMMDD_hhmmss'), $
						specstruct.trange[1]-specstruct.trange[0])
		
					print, string(format='(%"Save spectral struct in %s? (\"n\" or any key)")', ss_savname) 
					input = get_kbrd(/escape)

					if input ne 'n' then begin
						;get precipitation structure
						barrel_precip, specstruct, precipstruct=precipstruct
						timespan, trange ;reset trange 

						save, specstruct, filename='./savdat/'+ss_savname	
						save, precipstruct, filename='./savdat/'+ps_savname	

						help, precipstruct
						print, precipstruct.kp.x
						print, precipstruct.kp.y

						lc_savname = string(format='(%"brl%s_%s_%06d_lcurve.png")',$
							probe, $
							time_string(specstruct.trange[0], tformat='yyMMDD_hhmmss'), $
							specstruct.trange[1]-specstruct.trange[0])

						sp_savname = string(format='(%"brl%s_%s_%06d_spectra.png")', $
							probe, $
							time_string(specstruct.trange[0], tformat='yyMMDD_hhmmss'), $
							specstruct.trange[1]-specstruct.trange[0])

						wset, 1
						write_png, './savdat/'+lc_savname, tvrd(/true)
						wset, 0
						write_png, './savdat/'+sp_savname, tvrd(/true)

						wset, 1
						stop
					endif

				end
			else: flag = 0	
		endcase

	endrep until flag 

endwhile

end
