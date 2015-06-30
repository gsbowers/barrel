;+
; procedure: barrel_rebin
;
; Purpose:
;    rebin barrel time-series data stored in a tplot variable
;
; Example: 
;
;  IDL> timespan, '2013-01-27', 1, /day 
;  IDL> barrel_load_data, probe='1U', datatype='FSPC'
;  IDL> tplot_names
;  % Compiled module: TPLOT_NAMES.
;   1 brl1U_FSPC_Quality 
;   2 brl1U_FSPC1        
;   3 brl1U_FSPC2        
;   4 brl1U_FSPC3        
;   5 brl1U_FSPC4   
;  IDL> barrel_rebin, 2, 20
;  Creating tplot variable: 6 brl1U_FSPC1_20_bins
;  IDL> barrel_rebin, 'brl1U_FSPC2', 20
;  Creating tplot variable: 7 brl1U_FSPC2_20_bins
;  IDL> barrel_rebin, [4,5], 20        
;  Creating tplot variable: 8 brl1U_FSPC3_20_bins
;  Creating tplot variable: 9 brl1U_FSPC4_20_bins
;  IDL> tplot_names
;   1 brl1U_FSPC_Quality  
;   2 brl1U_FSPC1         
;   3 brl1U_FSPC2         
;   4 brl1U_FSPC3         
;   5 brl1U_FSPC4         
;   6 brl1U_FSPC1_20_bins 
;   7 brl1U_FSPC2_20_bins 
;   8 brl1U_FSPC3_20_bins 
;   9 brl1U_FSPC4_20_bins 
;
; Inputs:
;    VARNAME: String, Integer, or Array of strings or integers
;      specifying tplot variables
;    NBINS:  number of bins to group data into. Raw BARREL data
;      binned at 50ms, so nbins=20 rebins data to counts/[1 sec]
;
; Keywords:
;    NONE:
;
; Outputs:
;    NONE:   
;
; References:
;    http://themis.ssl.berkeley.edu/software.shtml
;
; Author:
;    Gregory S. Bowers
;    gsbowers@ucsc.edu
;    JUNE 30, 2015
;-  


pro barrel_rebin, var_name, nbins

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

for i = 0, count-1 do begin 

	var_name = var_names[i]
	
	; get data	
	get_data, var_name, data=data, limit=l, dlimit=dl 
	x = data.x
	y = data.y

	; make sure nbins is divisible by n_elements(y) 
	while n_elements(x) mod nbins ne 0 do begin
		rem = n_elements(x) mod nbins
		x = x[0:-(1+rem)]
		y = y[0:-(1+rem)]
	endwhile

	; rebin data (maybe use congrid)
	x = rebin(x,n_elements(x)/double(nbins))
	y = rebin(y+0.0d,n_elements(y)/double(nbins))*double(nbins)

	rebinned_data = {x:x, y:y}
	rebinned_var_name = var_name+'_'+string(nbins,Format='(I0)')+'_bins'

	; store rebinned data
	store_data, rebinned_var_name, data=rebinned_data

	; deterimine size of new bin 
	; convert to string freindly value 
	binwidth = ulong(50) * nbins ;binwidth in ms
	unit = 'ms'

	if (binwidth ge 1000) then begin
		binwidth = binwidth/1000.0 
		unit = 's'
	
		if (binwidth ge 60) then begin
			binwidth = binwidth/60.0
			unit = 'min'
		endif 
	endif

	; get plotting options of original data
	ysubtitle = '[cnts/'+string(binwidth, Format='(F0.1)')+unit+']'

	if tag_exist(dl, 'labels') then begin 
		labels = dl.labels
	endif else begin
		labels = ''
	endelse
	if tag_exist(dl, 'ytitle') then begin
		ytitle = dl.ytitle;+'_'+string(nbins, format='(I0)')+'_bins'
	endif else begin
		ytitle = rebinned_var_name
	endelse
	if tag_exist(dl, 'colors') then begin
		colors = dl.colors
	endif else begin
		colors = ''	
	endelse

	; set plot options for rebinned data
	options, rebinned_var_name, $
    labflag=1, labels=labels, $
    ytitle=ytitle, ysubtitle=ysubtitle, $
    colors=colors

endfor

return

end
