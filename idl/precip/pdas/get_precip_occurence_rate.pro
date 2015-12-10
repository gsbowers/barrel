function get_precip_occurence_rate, erange

	p = get_precip()	
	s = get_spectra()
	restore, filename='irbem_l_mlt.sav'

	w = where(s.params[0] gt erange[0] and s.params[0] le erange[1])
	
	mlt = mlt_irbem(w) 
	p = p(w)
	
	h = histogram(mlt, binsize=1, loc=xbin, min=0, max=24, reverse_indices=R)

	;use reverse indices to get cumulative precipitation duration
	duration = dblarr(24)
	for i=0,23 do begin	
		if r[i] eq r[i+1] then continue
		wr = r(r[i]:r[i+1]-1)
		t = p(wr).trange
		dt = t[1,*]-t[0,*]
		duration[i] = total(dt,/double)
	endfor	
	
	return, {h:h[0:-2], duration:duration, xbin:xbin[0:-2]}

end
