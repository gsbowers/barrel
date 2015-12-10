pro make_mlt_coverage, campaign=campaign

	if ~keyword_set(campaign) then $ 
		campaign = 1

	;MLT bins
	mltbins = findgen(24)
	nmltbins = n_elements(mltbins)

	mltcoverage = dblarr(nmltbins)

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

	;iterate through all payloads
	probes = barrel_get_campaign_probes(campaign)

	;iterate through all payloads
	timespan, date_begin, 50, /days
	for i = 0, n_elements(probes)-1 do begin

		probe = probes[i]
		barrel_load_data, probe=probe, datatype='GPS', version='v05'
	
		get_data, string(format='(%"brl%s_MLT_Kp2_T89c")', probe), data=mlt_data
		get_data, string(format='(%"brl%s_GPS_Alt")', probe), data=alt_data
		t = mlt_data.x
		mlt = mlt_data.y(where(finite(t)))
		alt = alt_data.y(where(finite(t)))

		;only look at times above 20km
		w = where(alt gt 20.0d)
		mlt = mlt(w)

		;24MLT counted same as 0MLT
		mlt = mlt mod 24

		for j=0, nmltbins-1 do begin	
			mltbin = mltbins[j]
			wj = where(mlt ge mltbin and mlt lt mltbin+1, count)
			if count eq 0 then continue
			mltcoverage(j) += count*4.0d
		endfor

		del_data, string(format='(%"brl%s_GPS_Alt")', probe)
		del_data, string(format='(%"brl%s_GPS_Lat")', probe)
		del_data, string(format='(%"brl%s_GPS_Lon")', probe)
		del_data, string(format='(%"brl%s_MLT_Kp2_T89c")', probe)
		del_data, string(format='(%"brl%s_MLT_Kp6_T89c")', probe)
		del_data, string(format='(%"brl%s_L_Kp2")', probe)
		del_data, string(format='(%"brl%s_L_Kp6")', probe)

	endfor
	
	save, mltbins, mltcoverage, filename='mltcoverage.sav'

end
