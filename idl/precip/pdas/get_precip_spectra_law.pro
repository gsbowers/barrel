function get_precip_spectra_law, campaign=campaign

	;get Leslies precip & spectra
	
	if ~keyword_set(campaign) then campaign = 1 
	
	if campaign eq 1 then $
		restore, filename='Barrel2013events.sav' $
	else $ 
		restore, filename='Barrel2014events.sav' 

	nevents = n_elements(event_start)
	trange = dblarr(2,nevents)

	pstruct = {payload:'', trange:[0.0d,0.0d], MLT_KP2_T89C:0.0d, L_KP2:0.0d}
	sstruct = {payload:'', params:[!VALUES.F_NAN, 0.0d], trange:[0.0d, 0.0d]}				

	precip = replicate(pstruct, nevents)
	spectra = replicate(sstruct, nevents)

	for j=0,nevents-1 do begin 

		trange = [0.0d, 0.0d]
		if campaign eq 1 then begin
			date_start = string(f='(%"%d-%s-%s")', year, month[j], day_start[j])
			date_end = string(f='(%"%d-%s-%s")', year, month[j], day_end[j])
			trange[0] = gettime(date_start)+event_start[j]*3600.0d
			trange[1] = gettime(date_end)+event_end[j]*3600.0d
			precip(j).MLT_KP2_T89c = mean(BAR_MLT_2013[j,*],/NAN)
			precip(j).L_KP2 = mean(BAR_L_2013[j,*],/NAN)

		endif else begin	
			;convert day/month/year/event_start into tdas time
			date = string(f='(%"%d-%s-%s")', year, month[j], day[j])
			trange[0] = gettime(date)+event_start[j]*3600.0d
			trange[1] = gettime(date)+event_end[j]*3600.0d
			precip(j).MLT_KP2_T89c = mean(BAR_MLT_2014[j,*],/NAN)
			precip(j).L_KP2 = mean(BAR_L_2014[j,*],/NAN)
		endelse

		spectra(j).trange = trange
		spectra(j).payload = payload_id[j]
		spectra(j).params[1] = e_fold[j]

		precip(j).trange =  trange
		precip(j).payload = payload_id[j]

	endfor

	return, {precip:precip, spectra:spectra}

end
