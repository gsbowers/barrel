function barrel_check_sp_fitrange, ss, threshold=threshold

	if ~keyword_set(threshold) then threshold=0.05

	ratio = ss.modvals/ss.bkgspec*ss.bkglive

	;only consider ratio in current fitrange
	edge_products, ss.ebins, mean=emean, width=ewidth
	w = where(emean ge ss.fitrange[0] and emean le ss.fitrange[1])
	ratio = ratio(w)

	;new fitrange where model is > 5% of background
	i = where(ratio lt threshold, count) 
	if count eq 0 then return, ss.fitrange
	if count gt 1 then i = i[0]

	new_fitrange = [ss.fitrange[0], (emean(w))[i]]

	return, new_fitrange

end
