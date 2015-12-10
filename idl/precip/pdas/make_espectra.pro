pro make_espectra, campaign=campaign

	if ~keyword_set(campaign) then $ 
		campaign = 1

	;e-folding energy bins
	bins = [[0,100],[100,200], [200,300],[300,400], [400,500],[500,600],[600,1e10]]
	nbins = n_elements(bins)/2.0d

	espectra = dblarr(nbins)

	r = get_precip_spectra(campaign=campaign)

	precip = r.precip
	spectra = r.spectra

	;iterate through precipitation events and histogram 
	;MLT times that precipitation was observed.  Do not
	;count precipitation observed by two balloons at same
	;MLT twice.   
	
	for i=0, n_elements(precip)-1 do begin

		p = precip(i)
		s = spectra(i)

		;get time range of first precipitation
		trange = p.trange  

		efold_bin=where(s.params[1] ge bins[0,*] and s.params[1] lt bins[1,*]) 
		espectra[efold_bin] += (p.trange[1]-p.trange[0])
		
	endfor

	save, bins, espectra, filename='espectra.sav'

	plot_espectra

end
