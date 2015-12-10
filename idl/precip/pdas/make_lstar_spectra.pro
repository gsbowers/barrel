pro make_lstar_spectra

	;e-folding energy bins
	;bins = [[0,100], [100,500], [500,700], [700,1e8]]
	bins = [[0,100],[100,200], [200,300],[300,400], [400,500],[500,600],[600,1e10]]
	nbins = n_elements(bins)/2.0d

	lbins = [2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,8.5]
	nlbins = n_elements(lbins)-1
	lspectra = dblarr(nbins, nlbins)

	precip = get_precip()
	spectra = get_spectra()

	;iterate through precipitation events and histogram 
	;MLT times that precipitation was observed.  Do not
	;count precipitation observed by two balloons at same
	;MLT twice.   
	
	for i=0, n_elements(precip)-1 do begin

		p = precip(i)
		s = spectra(i)

		;get time range of precipitation
		trange = p.trange  

		;get altitude, lat, lon, and kp at start and end of precip
		timespan, trange[0]-3*3600.0d, 6, /hours
		barrel_load_data, probe=p.payload, datat='GPS', version='v05'
		noaa_load_kp  
		
		get_data, string(format='(%"brl%s_GPS_Lat")', p.payload), data=lat_data
		get_data, string(format='(%"brl%s_GPS_Lon")', p.payload), data=lon_data
		get_data, string(format='(%"brl%s_GPS_Alt")', p.payload), data=alt_data
		get_data, string(format='(%"brl%s_L_Kp2")', p.payload), data=l_data
		get_data, 'Kp', data=kp_data
		t = alt_data.x

			

		wgps = where(t gt trange[0] and t lt trange[1])
		l = double(l_data.y(wgps))
		kp = double(kp_data.y)

		efold_bin = where(s.params[1] ge bins[0,*] and s.params[1] lt bins[1,*]) 
		for j=0, nlbins-1 do begin
			lbin = lbins[j]
			dl = lbins[j+1]-lbins[j]
			wj = where(l ge lbin and l le lbin+dl, count)
			if count eq 0 then continue
			lspectra[efold_bin, j] += count * 4.0d
		endfor
		
	endfor

	save, bins, lbins, lspectra, filename='lspectra.sav'

	stop

end
