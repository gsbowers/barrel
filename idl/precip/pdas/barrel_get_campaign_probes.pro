function barrel_get_campaign_probes, campaign

probes=-1

if campaign eq 1 then $ 
	probes = ['1D', '1K', '1I', '1G', '1C', '1H', '1Q', '1R', '1T', '1U', '1A', '1V']
if campaign eq 2 then $
	probes = ['2T', '2I', '2W', '2K', '2X', '2L', '2M', '2A', '2B', '2O', '2E', '2F']

;return, probes
return, ['2T']

end
