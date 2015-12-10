pro dmsplot

	bins = [[0,400], [400,500], [500,700], [700,1e8]]
	colors = [2,4,2505,6]

	nbins = n_elements(bins)/2.0d

	;plot settings
	xtitle = 'MLT'
	ytitle = 'duration [hrs]'
	title = ''
	xrange = [-12,12]
	;yrange = [0,1]
	charsize= 1.8

	;get histograms and normalizations
	hs = dblarr(nbins, 24)
	normhs = hs
	durations = dblarr(nbins, 24)
	for i = 0,nbins-1 do begin
		r = get_precip_occurence_rate(bins[*,i]) 
		hs[i,*] = r.h
		durations[i,*] = r.duration
	endfor

	;for i = 0, nbins-1 do begin
	;	normhs[i,*] = (hs[i,*]*durations[i,*])/norm
	;endfor
	durations = durations/3600.0d
	yrange = minmax(durations)

	thm_graphics_config
	window, xsize=700, ysize=400
	plot, xrange, yrange, xtitle=xtitle, ytitle=ytitle, xrange=xrange, yrange=yrange, xstyle=1, psym=1, charsize=charsize, title=title, $
		position = [0.1, 0.2, 0.8, 0.9]	

	for i = 0,nbins-1 do begin
		xbin = findgen(24)-12
		y = shift(durations[i,*],12)
		oplot, xbin, y, color=colors[i], thick=2
		plots, [0.82, 0.85], [0.6,0.6]-0.05*i, thick=3, /normal, color=colors[i]
		if i ne nbins-1 then $
			label = string(format='(%"%d-%d keV")', bins[*,i]) $
		else $ 
			label = string(format='(%"> %d keV")', bins[0,i]) 
		xyouts, 0.86, 0.6-0.01-0.05*i, /normal, label, charsize=1.2 
	endfor

	xyouts, 0.82, 0.75, /normal, 'Folding Energy', charsize=1.5

	stop
	
end
