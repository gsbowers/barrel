pro barrel_make_model_ratio, var_name, version=version, suffix=suffix, low_range=low_range, high_range=high_range

;aacgmidl

if ~keyword_set(version) then $
	version = 'v05'

;get list of named tplot variables
tplot_names, names=names

if isa(var_name, 'String') then begin
	
	;run var_name through strfilter on tplotnames
	var_names = strfilter(names, var_name,count=count)
	if count eq 0 then begin
		print, 'please check var_name'
		return
	endif
endif else begin
	;get varnames in tplotnames
	var_names = names[var_name-1] 
	count = n_elements(var_names)
endelse

;get probe ids for var_names 
probes = barrel_get_probes(names=var_names,/uniq)

;make sure that payloads specified in varname have associated 
;EHPM and mlat data loaded
for n = 0, n_elements(probes)-1 do begin 
	;need to EPHM data for payloads
	ephm_names = 'brl'+probes[n]+'_GPS_'+['Lat', 'Lon', 'Alt']
	if ~array_equal(strfilter(names, ephm_names), ephm_names) then $ 
		barrel_load_data, probe=probes[n], datatype='EPHM', version=version
	;need to get magnetic latitude for payloads

	;if keyword_set(aacgm) then begin 
	;	mlat_names = 'brl'+probes[n]+'_aacgm_'+['MLat', 'MLon'] 
	;	if ~array_equal(strfilter(names, mlat_names), mlat_names) then $ 
	;		barrel_load_aacgm_data, probes[n]
	;endif else begin 
	;	mlat_names = 'brl'+probes[n]+'_geo2mag_'+['MLat', 'MLon']
	;	if ~array_equal(strfilter(names, mlat_names), mlat_names) then $ 
	;		barrel_load_geo2mag_data, probes[n]
	;endelse

	;geo2mag_names = 'brl'+probes[n]+'_geo2mag_'+['MLat', 'MLon']
	;aacgm_names = 'brl'+probes[n]+'_AACGM_'+['MLat', 'MLon']
	;if ~array_equal(strfilter(names, aacgm_names), aacgm_names) then $ 
	;	barrel_load_aacgm_data, probes[n]
	;geo2mag_names = 'brl'+probes[n]+'_geo2mag_'+['MLat', 'MLon']
	;if ~array_equal(strfilter(names, geo2mag_names), geo2mag_names) then $ 
	;	barrel_load_geo2mag_data, probes[n]
endfor

;iterate through var_names and compute spectral ratio
var_name_ids = barrel_get_probes(names=var_names)
for i = 0, count-1 do begin 

	probe = var_name_ids[i]
	var_name = var_names[i]
	
	; get data	
	get_data, var_name, data=data, limit=l, dlimit=dl 

	if n_elements(tag_names(data)) ne 3 then return

	x = data.x ;time
	y = data.y ;spectra
	v = data.v ;energy

	; specify spectral ranges to take ratios of
	; specify spectral ranges to take ratios of
	if ~keyword_set(low_range) then low_range = [90,110] ;keV
	if ~keyword_set(high_range) then high_range = [3000,6000] ;keV

	wvlow  = where(v ge low_range[0]  and v le low_range[1])
	wvhigh  = where(v ge high_range[0]  and v le high_range[1])

	; calculate energy binwidths
	nv = n_elements(data.v)
  j = findgen(nv)*2+1 ;indices where e is defined (bin center)
  k = findgen(nv+1)*2 ;indices we want to know e (bin boundaries) hint: evenly spaced between log of bin centers 
  vboundaries = (10.0d^interpol(ALOG10(double(v)),j,k)) ;energy at bin boundaries
	vbinwidths = (shift(vboundaries,-1)-vboundaries)[0:-2]

	; compute ratios of obs integral flux to model integral flux
	ratio = dblarr(n_elements(x)) * !Values.F_NAN

	;if keyword_set(aacgm) then $ 
	;	get_data, 'brl'+probe+'_aacgm_MLat', data=mlat $
	;else $
	;	get_data, 'brl'+probe+'_geo2mag_MLat', data=mlat

	get_data, 'brl'+probe+'_GPS_Alt', data=alt
	
	for l = 1, n_elements(x)-2 do begin 
			
		;wx = where(mlat.x gt (x[l-1]+x[l])/2.0 and mlat.x le (x[l+1]+x[l])/2.0, count)	
		;if count eq 0 then continue

		wx = where(alt.x gt (x[l-1]+x[l])/2.0 and alt.x le (x[l+1]+x[l])/2.0, count)	
		if count eq 0 then continue

		;compute average mlat & alt at current time
		;w = where(finite(mlat.y(wx)),totalf)	
		;if totalf eq 0 then continue
		;mlat_avg = total(mlat.y(wx),/NAN)/totalf

		w = where(finite(alt.y(wx)),totalf)	
		if totalf eq 0 then continue
		alt_avg = total(alt.y(wx),/NAN)/totalf

		;bkgd_spectra_low = brl_makebkgd(v[wvlow], alt_avg, mlat_avg)
		;bkgd_spectra_high = brl_makebkgd(v[wvhigh], alt_avg, mlat_avg)
		bkgd_spectra_low = barrel_make_model_bkg(v[wvlow], alt_avg)		
		bkgd_spectra_high = barrel_make_model_bkg(v[wvhigh], alt_avg)		
	
		if isa(bkgd_spectra_low, /scalar) then $
			if bkgd_spectra_low eq -1 then continue

		bkgd_rate_low  = total(bkgd_spectra_low*vbinwidths[wvlow])
		bkgd_rate_high = total(bkgd_spectra_high*vbinwidths[wvhigh])

		ratio[l] = bkgd_rate_low/bkgd_rate_high

	endfor

	if high_range[0] gt 1000 then $
		ysubtitle=string(format='(%"[%0d-%0dkeV]/[%0d-%0dMeV]")', [low_range, high_range/1000]) $
	else $
		ysubtitle=string(format='(%"[%0d-%0dkeV]/[%4.2f-%4.2fMeV]")', [low_range, high_range/1000.0d])

	if ~keyword_set(suffix) then suffix = '' 

	label = 'model'
	;if keyword_set(aacgm) then label = 'aacgm'
	
	print, 'suffix is', suffix
	store_data, var_name+'_model_ratio'+suffix, data={x:x,y:ratio}, $
		dlimit={ysubtitle:ysubtitle, charsize:1.8, labflag:1, labels:label}

endfor

end
