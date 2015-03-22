pro barrel_spectrogram, varname, fs=fs 

if ~keyword_set(fs) then fs = 4.0

tplot_names, names=names

if isa(varname, 'String') then begin
  varnames = strfilter(names, varname,count=count)
  if count eq 0 then message, 'please check varname' 
endif else begin
  varnames = names[varname-1] 
  count = n_elements(varnames)
endelse

for i = 0, count-1 do begin 
  varname = varnames[i]
  ; get data  
  get_data, varname, data=d, limit=l, dlimit=dl 
  t = d.x
  x = d.y

  ;project x onto uniform time  
  tspan = t[-1]-t[0]
  ndata = tspan*fs
  xu = dblarr(ndata) * 0.0d + !Values.F_NAN
  ind = round((t-t[0])*fs)
  xu(ind) = d.y

  ;filter out dc component using savgol
  xu = xu - convol(xu, savgol(16,16,0,2), /EDGE_TRUNCATE)  

  ;take spectrogram of data
  s = spectrogram(xu, hanning(256), fs=fs)

  ;store power spectral density in tplot
  tname = varname+'_PSD'
  units = '['+strsplit(dl.ysubtitle, '[]', /extract)+'!E2!N/Hz]'
  store_data, tname, $
    data = {x:t[0]+s.time, y:s.psd, v:s.freq},$
    dlimit = {spec:1, x_no_interp:1, y_no_interp:1, $
      zlog:1, ztitle:units, $ 
      ytitle:dl.ytitle+' PSD', ysubtitle:'Frequency [Hz]', xtitle:'UTC', $
      charsize:1.8}

  tplot_options, 'xmargin', [20,20]

endfor

end
