;+
; procedure: barrel_spectrogram
;
; Purpose:
;    Create power spectral density spectrograms for timeseries 
;    defined in tplot and load spectrogram into tplot.  
;
;    DC Offset can be removed by subtracting off smoothed average of 
;    timeseries using savitsky-golay filter if detrend flag set
;
; Example: 
;
;  IDL> timespan, '2014-01-08', 1, /day
;  IDL> barrel_load_data, probe='2W', datatype='MAG', version='v04'
;  IDL> tplot_names
;  % Compiled module: TPLOT_NAMES.
;     1 brl2W_MAGN_Quality 
;     2 brl2W_MAG_X        
;     3 brl2W_MAG_Y        
;     4 brl2W_MAG_Z        
;     5 brl2W_MAG_BTotal   
;  IDL> barrel_spectrogram, [4,5], fs=4, /detrend 
;  IDL> tplot_names
;  IDL> tplot_names
;     1 brl2W_MAGN_Quality   
;     2 brl2W_MAG_X          
;     3 brl2W_MAG_Y          
;     4 brl2W_MAG_Z          
;     5 brl2W_MAG_BTotal     
;     6 brl2W_MAG_Z_PSD      
;     7 brl2W_MAG_BTotal_PSD 
;  IDL> tplot, [5,7] 
;
; Inputs:
;    VARNAME: String, Integer, or Array of strings or integers
;      specifying tplot variables
;
; Keywords:
;    FS:  Double  Sampling frequency.   
;    DETREND:  Set to detrend data using savitsky-golay filter
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
;    March 21, 2015
;-  

pro barrel_spectrogram, varname, fs=fs, detrend=detrend 

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

  ;remove dc component using savgol filter if detrend flag set
	if keyword_set(detrend) then $
  xu = xu - convol(xu, savgol(16,16,0,2), /EDGE_TRUNCATE)  

  ;take spectrogram of data
  s = spectrogram(xu, hanning(256), fs=fs)

  ;store power spectral density in tplot
  tname = varname+'_PSD'
	if keyword_set(detrend) then tname += 'X' 
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
