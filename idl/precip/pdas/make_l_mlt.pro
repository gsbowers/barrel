pro make_l_mlt 

	;get precipitation events
	;p = get_precip()
	restore, filename='precip.sav'
	n = n_elements(p)

	;arrays to store irbem output
	lstar = dblarr(n)
	mlt  = dblarr(n)
	lm = dblarr(n)

	for i=0,n-1 do begin
		p0 = p[i] 

		;get time, alt, lat, lon and kp from precipitation event
		t = mean(p0.trange)
		alt = p0.altitude	
		lat = p0.latitude
		lon = p0.longitude 
		kp = p0.kp.y	

		;get result of irbem_lstar
		r = irbem_lstar(t, alt, lat, lon, kp)
		lstar[i] = r.lstar
		mlt[i] = r.mlt
		lm[i] = r.lm
	endfor

	l_irbem = lm
	mlt_irbem = mlt
	save, l_irbem, mlt_irbem, filename="irbem_l_mlt.sav" 

	thm_graphics_config
	plot, abs(lm), yrange=[4,16], xrange=[0,200], xtitle='Event', ytitle='L Value', charsize=1.8
	oplot, abs(lm), thick=2
	oplot, p.l_kp2, color=2
	oplot, p.l_kp6, color=6

	plots, [180, 185], [14,14], thick=2
	xyouts, 185, 14, 'IRBEM', charsize=1.5

	plots, [180, 185], [13,13], color=2
	xyouts, 185, 13, 'Kp2', charsize=1.5

	plots, [180, 185], [12,12], color=6
	xyouts, 185, 12, 'Kp6', charsize=1.5

	stop 

	thm_graphics_config
	plot, (mlt), yrange=[0,24], xrange=[0,200], xtitle='Event', ytitle='MLT', charsize=1.8
	oplot, abs(mlt), thick=2
	oplot, p.mlt_kp2_t89c, color=2, linestyle=1
	oplot, p.mlt_kp6_t89c, color=6, linestyle=2

	plots, [180, 185], [24,24], thick=2
	xyouts, 185, 24, 'IRBEM', charsize=1.5

	plots, [180, 185], [23,23], color=2, linestyle=1
	xyouts, 185, 23, 'Kp2', charsize=1.5

	plots, [180, 185], [22,22], color=6, linestyle=2
	xyouts, 185, 22, 'Kp6', charsize=1.5
end
