pro barrel_pick_precip, timestamp, probe

version = 'v05'
dhour = 12*3600.0d ;seconds

;extract start of day from epoch in seconds 
tday = gettime(time_string(timestamp, tformat='YYYY-MM-DD')) 
;extract start of hour from 00:00 in seconds
hour = gettime(time_string(timestamp, tformat='YYYY-MM-DD/hh:mm:ss'))-tday

;dataytpes to load from bdas
datatypes = "SSPC EPHM FSPC"

;set timespan
timespan, tday, 2, /day
;data to display while searching for precipitation
bkg_energy = 120
barrel_load_data, probe=probe, datatype=datatypes, version=version
barrel_make_fspc, probe
barrel_load_model_bkg, probe, bkg_energy
noaa_load_kp
goes_load_xray, probe='15'

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
		goes_load_xray, probe='15'
	endif

	timespan, tstart, ddhour, /seconds

	;plot sspc of all payloads
	window, 5, ypos=0, xpos=0, xsize=500, ysize=500
	barrel_load_data, probe='*', datatype='SSPC', version=version
	tplot, tnames('*SSPC')
	
	;plot data
	window, 1, ysize=800
	wset, 1
	vars = string(format='(%"brl%s_SSPC brl%s_FSPC brl%s_%0dkeV brl%s_GPS_Alt GOES_xrs")',$
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
			'h': begin
					hour_end += 2*dhour ;advance hour of day
					ddhour += 2*dhour 
					flag = 1 ;continue
				end
			'j': begin
					hour_end += 4*dhour ;advance hour of day
					ddhour += 4*dhour 
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
						/bkg_renorm

					;calculate ss.moduals/ss.bkgspec and stop fit where 
					;model is < 5% of background
					new_fitrange = barrel_check_sp_fitrange(specstruct,threshold=0.05)
					sp_flag = 1					

					while sp_flag do begin 
						fitrange= new_fitrange
						print, 'redoing spectroscopy'
						barrel_spectroscopy, specstruct, date,hours, probe, /slow, $
							systematic_error_frac=0.1, fitrange=fitrange, numbkg=2,$ 
							starttimes = specstruct.trange[0], $
							endtimes = specstruct.trange[1], $
							startbkgs = reform(specstruct.bkgtrange[0,*]), $
							endbkgs = reform(specstruct.bkgtrange[1,*]), $
							/bkg_renorm

						wset, 0
						edge_products, specstruct.elebins, mean=elmean, width=elwidth
						flux = total(specstruct.elecmodel*elwidth)
						xyouts, 0.60, 0.55, /normal, $
							string(f='(%"efold: %9.2e eV")', specstruct.params[1])
						xyouts, 0.60, 0.53, /normal, $
							string(f='(%"model flux: %9.2e e-/cm2/s")', flux)

						print, 'stopped' 
						print, string(format='(%"old fitrange=[%g,%g]")', fitrange)
						print, string(format='(%"new fitrange=[%g,%g]")', new_fitrange)
						print, '>>>set "sp_flag" to 1 to redo fit'
						print, '>>>do ".c" to continue'
						sp_flag = 0

						stop

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
					print, "f to set flags in precip struct"
					input = get_kbrd(/escape)

					if input ne 'n' then begin
						;get precipitation structure
						barrel_precip_v2, specstruct, precipstruct=precipstruct
						timespan, trange ;reset trange 

						if input eq 'f' then begin
							print, 'Stopped.  Help \"specstruct\" and modify flags'
							print, '.c to continue saving'
							stop
						endif

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

						ap_savname = string(format='(%"brl%s_%s_%06d_allprobe.png")', $
							probe, $
							time_string(specstruct.trange[0], tformat='yyMMDD_hhmmss'), $
							specstruct.trange[1]-specstruct.trange[0])

						;annotate summary plots with additional information
						wset, 1
						barrel_annotate_quicklook, precipstruct, specstruct

						wset, 1
						write_png, './savdat/'+lc_savname, tvrd(/true)
						wset, 0
						write_png, './savdat/'+sp_savname, tvrd(/true)
						wset, 5
						timebar, precipstruct.trange
						write_png, './savdat/'+ap_savname, tvrd(/true)

						wset, 1
						stop
					endif

				end
			else: flag = 0	
		endcase

	endrep until flag 

endwhile

end
