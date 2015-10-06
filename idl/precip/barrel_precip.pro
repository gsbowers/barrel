pro barrel_precip, ss, precipstruct=precipstruct
;calculate maglat, MLT, L-shell etc from precipitation time specified in
;spectral structure

	ps = barrel_precip_struct()  

	payload = ss.payload
	trange = ss.trange

	get_data, string(format='(%"brl%s_GPS_Lat")', payload), data=data_lat
	get_data, string(format='(%"brl%s_GPS_Lon")', payload), data=data_lon
	get_data, string(format='(%"brl%s_GPS_Alt")', payload), data=data_alt
	get_data, string(format='(%"brl%s_MLT_Kp2_T89c")', payload), data=data_MLT_Kp2
	get_data, string(format='(%"brl%s_MLT_Kp6_T89c")', payload), data=data_MLT_Kp6
	get_data, string(format='(%"brl%s_L_Kp2")', payload), data=data_L_Kp2
	get_data, string(format='(%"brl%s_L_Kp6")', payload), data=data_L_Kp6

	t = data_lat.x(where(finite(data_lat.x)))
	w = where(t ge trange[0] and t le trange[1], count)
	
	lat = mean(data_lat.y(w), /NAN)
	lon = mean(data_lon.y(w), /NAN)
	alt = mean(data_alt.y(w), /NAN)
	MLT_Kp2 = mean(data_MLT_Kp2.y(w), /NAN)
	MLT_Kp6 = mean(data_MLT_Kp6.y(w), /NAN)
	L_Kp2 = mean(data_L_Kp2.y(w), /NAN)
	L_Kp6 = mean(data_L_Kp6.y(w), /NAN)

	;calculate aacgm MLat, MLon in degrees
	aacgmidl
	cnv_aacgm, lat, lon, alt, mlat, mlon, r, error	
	if error then begin
		mlat = !Values.F_NAN
		mlon = !Values.F_NAN
	endif

	;calculate magnetic conjugate 
	conj_coord_kp2 = geopack_conj_coord_T89(lat, lon, alt, t[0], 2)
	conj_coord_kp6 = geopack_conj_coord_T89(lat, lon, alt, t[0], 6)

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
	ps.conj_lat_kp2 = conj_coord_kp2[0]
	ps.conj_lon_kp2 = conj_coord_kp2[1]
	ps.conj_lat_kp6 = conj_coord_kp6[0]
	ps.conj_lon_kp6 = conj_coord_kp6[1]

	precipstruct = ps

end
