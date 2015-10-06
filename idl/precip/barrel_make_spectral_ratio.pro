pro barrel_make_spectral_ratio, var_name, suffix=suffix, low_range=low_range, high_range=high_range

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

;iterate through var_names and compute spectral ratio
for i = 0, count-1 do begin 

	var_name = var_names[i]
	
	; get data	
	get_data, var_name, data=data, limit=l, dlimit=dl 

	if n_elements(tag_names(data)) ne 3 then return

	x = data.x ;time
	y = data.y ;spectra
	v = data.v ;energy

	; specify spectral ranges to take ratios of
	if ~keyword_set(low_range) then low_range = [60,80] ;keV
	if ~keyword_set(high_range) then high_range = [500,540] ;keV

	wvlow  = where(v ge low_range[0]  and v le low_range[1])
	wvhigh = where(v ge high_range[0] and v ge high_range[1])

	; calculate energy binwidths
	nv = n_elements(data.v)
  j = findgen(nv)*2+1 ;indices where e is defined (bin center)
  k = findgen(nv+1)*2 ;indices we want to know e (bin boundaries) hint: evenly spaced between log of bin centers 
  vboundaries = (10.0d^interpol(ALOG10(double(v)),j,k)) ;energy at bin boundaries
	vbinwidths = (shift(vboundaries,-1)-vboundaries)[0:-2]
	
	; smooth spectra and compute ratios of high/low energy ranges
	w = where(v ge 520, complement=w_c)
	ratio = dblarr(n_elements(x))

	for l = 0, n_elements(x)-1 do $ 
		ratio[l] = total(y[l,wvlow]*vbinwidths[wvlow])/total(y[l,wvhigh]*vbinwidths[wvhigh])

	if high_range[0] gt 1000 then $
		ysubtitle=string(format='(%"[%0d-%0dkeV]/[%0d-%0dMeV]")', [low_range, high_range/1000]) $
	else $
		ysubtitle=string(format='(%"[%0d-%0dkeV]/[%4.2f-%4.2fMeV]")', [low_range, high_range/1000.0d])

	if ~keyword_set(suffix) then suffix = '' 

	store_data, var_name+'_ratio'+suffix, data={x:x,y:ratio}, $
		dlimit={ysubtitle:ysubtitle}

endfor

end
