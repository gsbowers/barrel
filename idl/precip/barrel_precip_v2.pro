pro barrel_precip_v2, ss, precipstruct=precipstruct
;calculate maglat, MLT, L-shell etc from precipitation time specified in
;spectral structure

	ps = barrel_precip_struct_v2()  

	payload = ss.payload
	trange = ss.trange

	get_data, string(format='(%"brl%s_GPS_Lat")', payload), data=data_lat
	get_data, string(format='(%"brl%s_GPS_Lon")', payload), data=data_lon
	get_data, string(format='(%"brl%s_GPS_Alt")', payload), data=data_alt
	get_data, string(format='(%"brl%s_MLT_Kp2_T89c")', payload), data=data_MLT_Kp2
	get_data, string(format='(%"brl%s_MLT_Kp6_T89c")', payload), data=data_MLT_Kp6
	get_data, string(format='(%"brl%s_L_Kp2")', payload), data=data_L_Kp2
	get_data, string(format='(%"brl%s_L_Kp6")', payload), data=data_L_Kp6

	t = data_lat.x
	w = where(finite(data_lat.y) and finite(data_lon.y) and finite(data_alt.y) and (t ge trange[0]) and (t le trange[1]), count)
		
	;get data at beginning/middle/end of interval
	get = [w(0),w(count/2),w(-1)]
	lat = data_lat.y(get)
	lon = data_lon.y(get)
	alt = data_alt.y(get)
	MLT_Kp2 = data_MLT_Kp2.y(get)
	MLT_Kp6 = data_MLT_Kp6.y(get)
	L_Kp2 = data_L_Kp2.y(get)
	L_Kp6 = data_L_Kp6.y(get)
	tdata = t(get)

	;calculate aacgm MLat, MLon in degrees
	aacgmidl
	mlat = dblarr(3)
	mlon = dblarr(3)
	for i = 0, 2 do begin
		cnv_aacgm, lat(i), lon(i), alt(i), mlat_out, mlon_out, r, error	
		if error then begin
			mlat(i) = !Values.F_NAN
			mlon(i) = !Values.F_NAN
		endif else begin
			mlat(i) = mlat_out
			mlon(i) = mlon_out
		endelse 
	endfor

	;calculate magnetic conjugate 
	kp_max = 7
	conj_coord_lat = dblarr(kp_max+1,3)
	conj_coord_lon = dblarr(kp_max+1,3)
	for kp = 1,kp_max do begin  
		for i=0,2 do begin
			conj_coord = geopack_conj_coord_T89(lat[i],lon[i],alt[i],tdata[i],kp)
			conj_coord_lat(kp,i) = conj_coord[0]
			conj_coord_lon(kp,i) = conj_coord[1]
		endfor
	endfor

	;get other payloads that are up
	probes = barrel_get_probes(/uniq)
	nprobes = n_elements(probes)
	payloads = strarr(20)
	nup = 0
	for i=0,nprobes-1 do begin
		probe = probes(i)
		if probe eq payload then continue	
		get_data, string(f='(%"brl%s_SSPC")', probe), data=sspc_data
		w = where(sspc_data.x ge trange[0] and sspc_data.x le trange[1])
		ww = where(finite(sspc_data.y(w)), count)
		if count eq 0 then continue
		payloads(nup) = probe
		nup += 1
	endfor

	;get kp values for 24 hours before and after
	;get_data, 'Kp', data=data_kp
	geo_window = 24*3600.0d
	tstart = trange[0]-geo_window
	tend = trange[0]+geo_window
	timespan, tstart, 3, /days
	noaa_load_kp
	get_data, 'Kp', data=data_kp
	w = where(data_kp.x gt tstart and data_kp.x lt tend, kp_count)
	if kp_count gt 16 then kp_count = 16 
	kp_data = data_kp.y(w)
	kp_time = data_kp.x(w)

	w = where(kp_time le t[0] and kp_time gt t[0]-3.0d)
	kp = kp_data(w)
	
	;load precip struct
	ps.payload = payload 
	ps.trange = trange
	ps.duration = trange[1] - trange[0]
	ps.bkgtrange = ss.bkgtrange
	ps.tdata = tdata
	ps.latitude = lat
	ps.longitude = lon
	ps.altitude = alt
	ps.MLT_Kp2_T89c = MLT_Kp2
	ps.MLT_Kp6_T89c = MLT_Kp6
	ps.l_kp2 = L_kp2
	ps.l_kp6 = L_kp6
	ps.maglat = mlat
	ps.maglon = mlon
	ps.kp.x = kp_time(w)
	ps.kp.y = kp
	ps.kp_data.x = kp_time
	ps.kp_data.y = kp_data
	ps.conj_lat = conj_coord_lat
	ps.conj_lon = conj_coord_lon
	ps.payloads = payloads 
	ps.npayloads = nup

	precipstruct = ps

end
