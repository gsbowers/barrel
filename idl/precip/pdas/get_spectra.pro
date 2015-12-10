function get_spectra, campaign=campaign

if ~keyword_set(campaign) then $ 
	campaign = 1

probes = barrel_get_campaign_probes(campaign)

if campaign eq 1 then $ 
	probes = ['1D', '1K', '1I', '1G', '1C', '1H', '1Q', '1R', '1T', '1U', '1A', '1V']

;create array of precipitation structures
spectra = replicate(barrel_sp_make(numsrc=1, numbkg=2, /slow), 500)
counter = 0

for i=0, n_elements(probes)-1 do begin
	
	datafiles = FILE_Search(string(format='(%"../savdat/campaign%d/%s/*spectra.sav")', campaign, probes[i]))
	for j=0, n_elements(datafiles)-1 do begin 
		restore, datafiles[j]
		spectra[counter] = specstruct
		counter += 1
	endfor

endfor

spectra = spectra(0:counter-1)

save, spectra, filename="spectra.sav"

return, spectra

end
