pro barrel_load_model_bkg, probe, energylist

	;get sspc data
	get_data, string(format="(%'brl%s_SSPC')", probe), data=data, limit=limit, dlimit=dl

	x = data.x ;time
	y = data.y ;spectra
	v = data.v ;energy

	for i=0, n_elements(energylist)-1 do begin

		;array for bkg model
		bkg = dblarr(n_elements(x)) * !Values.F_NAN

		;get lightcurve for given energy
		;store light curve
		energy = energylist[i]
		wv = where(v ge energy, vcount)
		if vcount gt 1 then wv = wv[0]
		lc_name = string(format="(%'brl%s_SSPC_%dkeV')", probe, energy)
		store_data, lc_name, data={x:x, y:y[*,wv]}, limit={ysubtitle:string(format="(%'\[%s\]')", limit.ztitle)}

		;get altitude of payload
		get_data, string(format="(%'brl%s_GPS_Alt')", probe), data=data
		t = data.x
		alt = data.y

		;get background from altitude
		;interpolate alitude cadence to sspc cadence
		for l=1, n_elements(x)-2 do begin
			wx = where(t gt (x[l-1]+x[l])/2.0 and t le (x[l+1]+x[l])/2.0, count)	
			if count eq 0 then continue

			w = where(finite(alt(wx)),totalf)	
			if totalf eq 0 then continue
			alt_avg = total(alt(wx),/NAN)/totalf

			bkg[l] = barrel_make_model_bkg(energy, alt_avg)  	
			if bkg[l] lt 0 then bkg[l] = !Values.F_NAN

		endfor

		;store background
		bkg_name = string(format="(%'brl%s_bkg_%dkeV')", probe, energy)
		store_data, bkg_name, data={x:x, y:bkg}, limit={ysubtitle:string(format="(%'\[%s\]')", limit.ztitle)}

		;store lightcurve and bkg in one variable
		store_data, string(format="(%'brl%s_%dkeV')", probe, energy), data=[lc_name, bkg_name], limit={labflag:1, labels:['SSPC', 'bkg'], colors:[0,6]} 

	endfor

end
