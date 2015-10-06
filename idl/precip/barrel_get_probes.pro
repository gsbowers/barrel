function barrel_get_probes, names=names, uniq=uniq

	if ~keyword_set(names) then $
		tplot_names, names=names

	if names eq !NULL then $
		return, !NULL
	
	;get array of all payload IDS in tplot_names 
	probes = strsplit(stregex(names, 'brl[0-9][A-Z]', /EXTRACT), 'brl', /EXTRACT)
	if isa(probes, 'LIST') eq 1 then probes=probes.toArray() 

	if keyword_set(uniq) then $
		return, probes(UNIQ(probes, sort(probes))) $
	else $
		return, probes	
end
