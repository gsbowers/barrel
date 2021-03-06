pro plot_alt_coverage, addtitle=addtitle

	;restore mltspectra and bins
	restore, filename='altcoverage.sav'
	altcoverage = altcoverage/3600.0d

	;plot settings
	xtitle = 'Alt [km]'
	ytitle = 'Duration [hrs]'
	title = addtitle+' Total Coverage'
	xrange = minmax(altbins)
	yrange = minmax(altcoverage)
	font = -1 
	charthick = 1.8 
	charsize= 2

	thm_graphics_config
	window, xsize=700, ysize=400
	plot, xrange, yrange, xtitle=xtitle, ytitle=ytitle, $ 
		xrange=xrange, yrange=yrange, xstyle=1, psym=1, charsize=charsize, $
    title=title, position = [0.15, 0.2, 0.8, 0.9], font=font,$
		charthick=charthick	, xthick=2, ythick=2

	x = altbins
	y = altcoverage
	oplot, x, y, thick=2

end
