pro barrel_make_ratios, var_name, suffix=suffix, low_range=low_range, high_range=high_range

low_range = [80,90]
high_range = [3000,6000]

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

	barrel_make_spectral_ratio, var_name, suffix=suffix, low_range=low_range, high_range=high_range

	barrel_make_model_ratio, var_name, suffix=suffix, low_range=low_range, high_range=high_range

	get_data, var_name+'_ratio'+suffix, data=obs
	get_data, var_name+'_model_ratio'+suffix, data=model, dlimit=dl
	;scale model ratio to accentuate altitude effects
	scale_model= (model.y-mean(model.y,/NAN))*20.0

	store_data, var_name+'_model_ratio'+suffix, $
		data={x:obs.x, y:scale_model+median(obs.y)*1.15}, $
		dlimit=dl
	
	store_data, var_name+'_ratios'+suffix, data=var_name+['','_model']+'_ratio', $
		dlimit={charsize:1.8, colors:[0,6]}

endfor

end
