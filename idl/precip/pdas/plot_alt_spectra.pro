pro plot_alt_spectra, addtitle=addtitle

	;restore mltspectra and bins
	restore, filename='altspectra.sav'
	nbins = n_elements(bins)/2.0d
	altspectra = altspectra/3600.0d

	;plot settings
	xtitle = 'Alt [km]'
	ytitle = 'Duration [hrs]'
	title = addtitle+' Observed Precipitation'
	xrange = minmax(altbins)
	yrange = minmax(altspectra)
	;colors = [2,4,2505,6]
	colors = [0,2,1,3,4,2505,6]
	font = -1 
	charthick = 1.8 
	charsize= 2

	thm_graphics_config
	window, xsize=700, ysize=400
	plot, xrange, yrange, xtitle=xtitle, ytitle=ytitle, $ 
		xrange=xrange, yrange=yrange, xstyle=1, psym=1, charsize=charsize, $
    title=title, position = [0.15, 0.2, 0.8, 0.9], font=font,$
		charthick=charthick	, xthick=2, ythick=2

	for i = 0,nbins-1 do begin
		xbin = altbins
		y = altspectra[i,*]
		oplot, xbin, y, color=colors[i], thick=2
		plots, [0.82, 0.85], [0.6,0.6]-0.05*i, thick=3, /normal, color=colors[i]
		if i ne nbins-1 then $
			label = string(format='(%"%d-%d keV")', bins[*,i]) $
		else $ 
			label = string(format='(%"> %d keV")', bins[0,i]) 
		xyouts, 0.86, 0.6-0.01-0.05*i, /normal, label, charsize=1.2 
	endfor

	xyouts, 0.82, 0.75, /normal, 'Folding Energy', charsize=1.5

end
