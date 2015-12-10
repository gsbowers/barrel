function get_precip, campaign=campaign

if ~keyword_set(campaign) then $ 
	campaign = 1
probes = barrel_get_campaign_probes(campaign)

;create array of precipitation structures
precip = replicate(barrel_precip_struct_v2(), 500)
counter = 0

for i=0, n_elements(probes)-1 do begin

	probe = probes[i]
	campaign = strmid(probe,0,1)
	
	datafiles = FILE_Search(string(format='(%"../savdat/campaign%d/%s/*precip.sav")', campaign, probe))
	for j=0, n_elements(datafiles)-1 do begin 
		restore, datafiles[j]
		precip[counter] = precipstruct
		counter += 1
	endfor

endfor

precip = precip(0:counter-1)

save, precip, filename="precip.sav"

return, precip

end
