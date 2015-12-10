function quicklook_url, precip_struct, path=path

	p = precip_struct

	t0 = p.trange[0]
	t1 = p.trange[1]
	duration = t1-t0

	url = $
		string(format='(%"twop.ly/precip/%s/%s/brl%s_%s_%06d_quicklook.png")', $
		p.payload, time_string(t0, tformat='yyMMDD'), p.payload, $
		time_string(t0, tformat='yyMMDD_hhmmss'), uint(duration))

	localpath = $
		string(format='(%"./%s/brl%s_%s_%06d_precip.sav")', $
		p.payload, p.payload, $
		time_string(t0, tformat='yyMMDD_hhmmss'), uint(duration))

	if keyword_set(path) then return, localpath
	return, url

end
