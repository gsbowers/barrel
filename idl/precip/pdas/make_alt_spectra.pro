pro make_alt_spectra, campaign=campaign

	if ~keyword_set(campaign) then $ 
		campaign = 1

	;e-folding energy bins
	;altitude energy bins
	alt_min = 20
	alt_max = 40
	;bins = [[0,100], [100,500], [500,700], [700,1e8]]
	bins = [[0,100],[100,200], [200,300],[300,400], [400,500],[500,600],[600,1e10]]
	altbins = alt_min+findgen((alt_max-alt_min))
	nebins = n_elements(bins)/2.0d
	naltbins = n_elements(altbins)

	altspectra = dblarr(nebins, naltbins)

	r = get_precip_spectra(campaign=campaign)

	precip = r.precip 
	spectra = r.spectra

	;iterate through precipitation events and histogram 
	;count precipitation observed by two balloons at same
	;MLT twice.   
	
	for i=0, n_elements(precip)-1 do begin

		p = precip(i)
		s = spectra(i)

		;get time range precipitation
		trange = p.trange  

		;get alt
		timespan, trange[0]-3*3600.0d, 1, /seconds
		barrel_load_data, probe=p.payload, datat='GPS', version='v05'
		
		get_data, string(format='(%"brl%s_GPS_Alt")', p.payload), data=alt_data

		t = alt_data.x
		wgps = where(t gt trange[0] and t lt trange[1])
		alt = double(alt_data.y(wgps))
		efold_bin = where(s.params[0] ge bins[0,*] and s.params[0] lt bins[1,*]) 

		for j=0, naltbins-1 do begin 
			altbin = altbins[j] 	
			wj = where(alt ge altbin and alt le altbin+1, count)
			if count eq 0 then continue
			altspectra(efold_bin, j) += count*4.0d
		endfor
		
	endfor

	save, bins, altbins, altspectra, filename='altspectra.sav'

end
