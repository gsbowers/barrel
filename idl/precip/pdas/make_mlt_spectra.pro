pro make_mlt_spectra, campaign=campaign

	if ~keyword_set(campaign) then $ 
		campaign = 1

	;e-folding energy bins
	;bins = [[0,400], [400,500], [500,700], [700,1e8]]
	;bins = [[0,100],[100,200], [200,300],[300,400], [400,500],[500,600],[600,1e10]]
	bins = [[0,100],[100,200], [200,300],[300,400], [400,1e10]]
	nbins = n_elements(bins)/2.0d

	mltspectra = dblarr(nbins, 24)

	r = get_precip_spectra(campaign=campaign)
	;r = get_precip_spectra_law(campaign=campaign)

	precip = r.precip 
	spectra = r.spectra

	;iterate through precipitation events and histogram 
	;MLT times that precipitation was observed.  Do not
	;count precipitation observed by two balloons at same
	;MLT twice.   
	
	for i=0, n_elements(precip)-1 do begin

		p = precip(i)
		s = spectra(i)

		;find beginning and ending MLT during precipitaiton

		;get time range of first precipitation
		trange = p.trange  

		;stop and reconsider if trange is greater than 20 hours
		;want to check that mlt_start =/= mlt_end(+1day)
		;if (trange[1]-trange[0])/3600.d gt 22.0d then stop

		;get altitude, lat, lon, and kp at start and end of precip
		timespan, trange[0]-3*3600.0d, 6, /hours
		barrel_load_data, probe=p.payload, datat='GPS', version='v05'
		noaa_load_kp  
		
		get_data, string(format='(%"brl%s_GPS_Lat")', p.payload), data=lat_data
		get_data, string(format='(%"brl%s_GPS_Lon")', p.payload), data=lon_data
		get_data, string(format='(%"brl%s_GPS_Alt")', p.payload), data=alt_data
		get_data, string(format='(%"brl%s_MLT_Kp2_T89c")', p.payload), data=mlt_data
		get_data, 'Kp', data=kp_data

		t = lat_data.x
		wgps = where(t gt trange[0] and t lt trange[1])
		;lat = double(lat_data.y(wgps))
		;lon = double(lon_data.y(wgps))
		;alt = double(alt_data.y(wgps))
		t = mlt_data.x
		wmlt = where(t gt trange[0] and t lt trange[1])
		mlt = double(mlt_data.y(wmlt))
		kp = double(kp_data.y)

		mlt = mlt mod 24

		efold_bin = where(s.params[1] ge bins[0,*] and s.params[1] lt bins[1,*]) 
		for j=0, 23 do begin
			wj = where(mlt ge j and mlt le j+1, count)
			if count eq 0 then continue
			mltspectra[efold_bin, j] += count * 4.0d
		endfor
		
	endfor

	save, bins, mltspectra, filename='mltspectra.sav'

end
