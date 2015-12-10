function get_filename, p

	t0 = p.trange[0]
	t1 = p.trange[1]
	duration = t1-t0

	filename = string(format='(%"%s/%s/brl%s_%s_%06d_quicklook.png")', $
		p.payload, time_string(t0, tformat='yyMMDD'), p.payload, $
		time_string(t0, tformat='yyMMDD_hhmmss'), uint(duration))

	return, filename

end
