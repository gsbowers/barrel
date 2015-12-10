pro compare_bdas_irbem

	probe = '1C'
	
	;timespan covering first compaign
	timespan, '2013-01-01', 60, /day
	barrel_load_data, probe=probe, datatype='GPS', version='v05' 
	noaa_load_kp

	;get data from tplot variables
	get_data, string(format='(%"brl%s_L_Kp2")', probe), data=l_data
	get_data, string(format='(%"brl%s_GPS_Lat")', probe), data=lat_data
	get_data, string(format='(%"brl%s_GPS_Lon")', probe), data=lon_data
	get_data, string(format='(%"brl%s_GPS_Alt")', probe), data=alt_data
	get_data, string(format='(%"%s")', "Kp"), data=kp_data
	
	;get time
	t = alt_data.x
	
	;only finite values
	w = where(finite(t), count)
	
	;only 100000 values, size of IRBEM NTIME_MAX
	w = w[0:99999]
	t = t(w)
	lat = lat_data.y(w)
	lon = lon_data.y(w)
	alt = alt_data.y(w)
	l = l_data.y(w)

	;interpolate kp onto tdas time, t
	;kp = interpol(kp_data.y, kp_data.x, t, /Quadratic)		
	
	r = irbem_lstar(t, alt, lat, lon, 2.0d)

	plot, t-t[0], abs(r.lm), yrange=[0,10] 
	oplot, t-t[0], l, color=2

	print, where(finite(l,/NAN))

	stop

end
