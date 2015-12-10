pro plot_mlt_coverage, addtitle=addtitle, shiftmlt=shiftmlt

	if ~keyword_set(addtitle) then addtitle= ''

	;restore mltspectra and bins
	restore, filename='mltcoverage.sav'
	mltcoverage = mltcoverage/3600.0d

	x = mltbins
	y = mltcoverage

	if keyword_set(shiftmlt) then begin 
		x = mltbins-12
		y = shift(mltcoverage,-12)
	endif

	;plot settings
	xtitle = 'MLT : T89c Kp2'
	ytitle = 'Duration [hrs]'
	title = addtitle+' Total Coverage > 20km'
	xrange = minmax(x)
	yrange = minmax(y)
	font = -1 
	charthick = 1.8 
	charsize= 2

	thm_graphics_config
	window, xsize=700, ysize=400
	plot, xrange, yrange, xtitle=xtitle, ytitle=ytitle, $ 
		xrange=xrange, yrange=yrange, xstyle=1, psym=1, charsize=charsize, $
    title=title, position = [0.15, 0.2, 0.8, 0.9], font=font,$
		charthick=charthick	, xthick=2, ythick=2

	oplot, x, y, thick=2

end
