pro compare_gsb_law, campaign=campaign

if ~keyword_set(campaign) then campaign = 1

r_gsb = get_precip_spectra(campaign=campaign)
p_gsb = r_gsb.precip
s_gsb = r_gsb.spectra

r_law = get_precip_spectra_law(campaign=campaign)
p_law = r_law.precip
s_law = r_law.spectra

;iterate through law events and find corresponding gsb event

nlaw = n_elements(p_law)

for i=0, nlaw-1 do begin

	tstart = p_law(i).trange[0]
	tend = p_law(i).trange[1]
	probe = p_law(i).payload

	w = where(p_gsb.payload eq probe, count)
	if count eq 0 then continue
	tgsb = p_gsb(w).trange

	m = where((((tgsb[0,*] ge tstart) and (tgsb[0,*] le tend)) OR $
						((tgsb[1,*] ge tstart) and (tgsb[1,*] le tend)) OR $
						((tgsb[0,*] lt tstart) and (tgsb[1,*] gt tend))), count) 

	if count eq 0 then begin
		print, 'NO MATCH!:  ', p_law[i].payload, $
			time_string(p_law[i].trange, tf='YYYY-MM-DD/hh:mm:ss')
		continue
	endif 

	mp_gsb = (p_gsb(w))(m)
	mp_law = p_law(i)

	ms_gsb = (s_gsb(w))(m)
	ms_law = s_law(i)

	print, string(f='(%"Event %d")', i)
	print, string(f='(%"LAW %s %s, duration %6.0f s, e-fold %f keV")', mp_law.payload, time_string(mp_law.trange[0], tf='YYYY-MM-DD/hh:mm:ss'), (mp_law.trange[1]-mp_law.trange[0]), ms_law.params[1]) 
	print, string(f='(%"GSB %s %s, duration %6.0f s, e-fold %f keV")', mp_gsb.payload, time_string(mp_gsb.trange[0], tf='YYYY-MM-DD/hh:mm:ss'), (mp_gsb.trange[1]-mp_gsb.trange[0]), ms_gsb.params[1]) 
	print, quicklook_url(mp_gsb)
	print, "" 
	
end

stop

end
