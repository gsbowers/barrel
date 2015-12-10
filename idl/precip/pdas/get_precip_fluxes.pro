function get_precip_fluxes

	vers = 'v05'
	energy = 110

	;get precipitation events
	precip = get_precip()		
	nevents = n_elements(precip)

	;make array of fluxes
	flux_struct = {tstart:0.0d, counts:0.0d} 
	fluxes = replicate(flux_struct, nevents)
	counter = 0

	;get list of probes
	;probes = precip(uniq(precip.payload, sort(precip.payload))).payload
	probes = ['1D', '1K', '1I', '1G', '1C', '1H', '1Q', '1R', '1T', '1U', '1A', '1V']
	;iterate through probes
	for n =0, n_elements(probes)-1 do begin
	
		probe = probes[n]
		w = where(precip.payload eq probe, count)

		tstarts = precip(w).trange[0]
		tends = precip(w).trange[1]

		tstart_last = -1
		tend_last = -1

		for i=0, count-1 do begin

			tstart = tstarts[i]
			tend = tends[i]

			timespan, tstart, tend-tstart, /seconds
			barrel_load_data, probe=probe, datatype='SSPC GPS EPHM', version=vers
			barrel_load_model_bkg, probe, [energy]

			;calculate flux of observed precipitation in counts
			varname = string(format='(%"brl%s_bkg_%dkeV")', probe, energy)
			get_data, varname, data=bkg
			varname = string(format='(%"brl%s_SSPC_%dkeV")', probe, energy)
			get_data, varname, data=sspc

			v = where(sspc.x ge tstart and sspc.x le tend)	
			sflux = (sspc.y(v) - bkg.y(v))*(tend-tstart)	
			good = where(finite(sflux))
			dt = n_elements(good)*32.0d

			flux = total(sflux(good), /double)*dt
			flux_struct.tstart = tstart
			flux_struct.counts = flux
			fluxes(counter) = flux_struct
			counter += 1

			tstart_last = tstart
			tend_last = tend

		endfor

	endfor

	return, fluxes
end
