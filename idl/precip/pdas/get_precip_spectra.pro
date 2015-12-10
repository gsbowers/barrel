function get_precip_spectra, campaign=campaign

if ~keyword_set(campaign) then $ 
	campaign = 1

p = get_precip(campaign=campaign)
s = get_spectra(campaign=campaign)

;apply cuts
;exclude blacklisted events
w1 = where(strmatch(p.notes, 'x*') ne 1,count1)
p = p(w1)
s = s(w1)

return, {precip:p, spectra:s}

end
