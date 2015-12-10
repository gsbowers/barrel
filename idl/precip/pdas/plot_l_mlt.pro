pro plot_l_mlt, kp=kp, irbem=irbem

	if ~keyword_set(kp) then kp=2
	note = 'kp auto'
	if kp eq 2 then note = 'bdas T89c Kp=2'
	if kp eq 6 then note = 'bdas T89c Kp=6'

	if keyword_set(irbem) then note = 'IRBEM T89c Kp=obs'
		
	;get precipitation and spectra data
	p = get_precip()
	s = get_spectra()
	n = n_elements(p)
	
	;plot settings
	xtitle = 'MLT'
	ytitle = 'L Value'
	title = 'BARREL 2013 Precipitation'+' '+note
	xrange = [0,24]
	yrange = [0,25]
	charsize= 1.8
	xthick=2
	ythick=2

	thm_graphics_config
	window, xsize=700, ysize=400
	plot, xrange, yrange, xtitle=xtitle, ytitle=ytitle, xrange=xrange, yrange=yrange, xstyle=1, psym=1, charsize=charsize, title=title, ythick=ythick, xthick=xthick	

	;assign weights proportional to spectral hardness
	weights = ALOG10(s.params[0])


	if keyword_set(irbem) then begin

		restore, filename='irbem_l_mlt.sav'

		oplot, mlt_irbem, abs(l_irbem), psym=1
		for i=0, n-1 do $ 
			plots, (mlt_irbem)[i], (abs(l_irbem))[i], psym=5, $
					symsize=weights(i)
		stop

	endif else begin
		if kp eq -1 then begin
	
			;make sure we're assigned correct MLT and L based on kp
			wkp2 = where(p.kp.y le 2)
			wkp6 = where(p.kp.y gt 2) 	
	
			for i=0, n_elements(wkp2)-1 do begin 
				;xyouts, (p(wkp2).MLT_KP2_T89C)[i], (p(wkp2).L_KP2)[i], $
				;	(p(wkp2).payload)[i]
				plots, (p(wkp2).MLT_KP2_T89C)[i], (p(wkp2).L_KP2)[i], psym=1
				plots, (p(wkp2).MLT_KP2_T89C)[i], (p(wkp2).L_KP2)[i], psym=5, $
					symsize=(weights(wkp2))[i], color=2
			endfor
	
			for i=0, n_elements(wkp6)-1 do begin 
				;xyouts, (p(wkp6).MLT_KP6_T89C)[i], (p(wkp6).L_KP6)[i], $
				;	(p(wkp6).payload)[i]
				plots, (p(wkp6).MLT_KP6_T89C)[i], (p(wkp6).L_KP6)[i], psym=1
				plots, (p(wkp6).MLT_KP6_T89C)[i], (p(wkp6).L_KP6)[i], psym=5, $
					symsize=(weights(wkp6))[i], color=6
			endfor
		endif 
		
		if kp eq 6 then begin
			for i=0, n-1 do begin 
				plots, (p.MLT_KP6_T89C)[i], (p.L_KP6)[i], psym=1
				plots, (p.MLT_KP6_T89C)[i], (p.L_KP6)[i], psym=5, $
					symsize=weights(i)
			endfor
		endif 
		
		if kp eq 2 then begin
			for i=0, n-1 do begin 
				plots, (p.MLT_KP2_T89C)[i], (p.L_KP2)[i], psym=1
				plots, (p.MLT_KP2_T89C)[i], (p.L_KP2)[i], psym=5, $
					symsize=weights(i)
			endfor
		endif
	endelse
						
	stop	

end
