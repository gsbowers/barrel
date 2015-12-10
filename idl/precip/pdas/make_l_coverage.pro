pro make_l_coverage, campaign=campaign
	
	if ~keyword_set(campaign) then $
		campaign = 1

	;L bins
	lbins = [2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,8.5]
	nlbins = n_elements(lbins)-1

	lcoverage = dblarr(nlbins)

	;first campaign
	if campaign eq 1 then begin 
		date_begin = '2013-01-01/00:00'
		date_end = '2013-02-17/00:00'
	endif

	;second campaign
	if campaign eq 2 then begin 
		date_begin = '2013-12-25/00:00'
		date_end = '2014-02-12/00:00'
	endif

	version = 'v05'

	probes = barrel_get_campaign_probes(campaign)
	
	;iterate through all payloads
	timespan, date_begin, 50, /days
	for i = 0, n_elements(probes)-1 do begin

		probe = probes[i]
		barrel_load_data, probe=probe, datatype='GPS', version='v05'
	
		get_data, string(format='(%"brl%s_L_Kp2")', probe), data=l_data
		get_data, string(format='(%"brl%s_GPS_Alt")', probe), data=alt_data
		t = l_data.x
		l = l_data.y(where(finite(t)))
		alt = alt_data.y(where(finite(t)))

		;only look at times above 20km
		w = where(alt gt 20.0d)
		l = l(w)

		for j=0, nlbins-1 do begin	
			lbin = lbins[j]
			dl = lbins[j+1]-lbins[j] 
			wj = where(l ge lbin and l le lbin+dl, count)
			if count eq 0 then continue
			lcoverage(j) += count*4.0d
		endfor

		del_data, string(format='(%"brl%s_GPS_Alt")', probe)
		del_data, string(format='(%"brl%s_GPS_Lat")', probe)
		del_data, string(format='(%"brl%s_GPS_Lon")', probe)
		del_data, string(format='(%"brl%s_MLT_Kp2_T89c")', probe)
		del_data, string(format='(%"brl%s_MLT_Kp6_T89c")', probe)
		del_data, string(format='(%"brl%s_L_Kp2")', probe)
		del_data, string(format='(%"brl%s_L_Kp6")', probe)

	endfor
	
	save, lbins, lcoverage, filename='lcoverage.sav'

end
