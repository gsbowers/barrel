pro make_alt_coverage, campaign=campaign

	if ~keyword_set(campaign) then $ 
		campaign = 1

	;e-folding energy bins
	;altitude energy bins
	alt_min = 20
	alt_max = 40
	altbins = alt_min+findgen((alt_max-alt_min))
	naltbins = n_elements(altbins)

	altcoverage = dblarr(naltbins)
	
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
	
		get_data, string(format='(%"brl%s_GPS_Alt")', probe), data=alt_data
		t = alt_data.x
		alt = alt_data.y(where(finite(t)))

		for j=0, naltbins-1 do begin	
			altbin = altbins[j]
			wj = where(alt ge altbin and alt le altbin+1, count)
			if count eq 0 then continue
			altcoverage(j) += count*4.0d
		endfor

		del_data, string(format='(%"brl%s_GPS_Alt")', probe)
		del_data, string(format='(%"brl%s_GPS_Lat")', probe)
		del_data, string(format='(%"brl%s_GPS_Lon")', probe)
		del_data, string(format='(%"brl%s_MLT_Kp2_T89c")', probe)
		del_data, string(format='(%"brl%s_MLT_Kp6_T89c")', probe)
		del_data, string(format='(%"brl%s_L_Kp2")', probe)
		del_data, string(format='(%"brl%s_L_Kp6")', probe)

	endfor
	
	save, altbins, altcoverage, filename='altcoverage.sav'

end
