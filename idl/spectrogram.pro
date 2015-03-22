;+
; Function: spectrogram
;
; Purpose:
;    Return power spectral density spectrogram for 1D time series, x. 
;    Break x up into floor((Nx-Noverlap)/(Nw-Noverlap)) intervals 
;    consisting of n_elements(w), where w is the user specified
;    windowing function. Inverals overlap by 50%, or n_elements(w)/2. 
;    For each interval compute the modified short-time series 
;    fourier transform by taking the fast fourier transform of x*w. 
;    From the N fft coefficients, defined in IDL as 
;
;         D_k = (1/N)*Sum^{N-1}_{j=0} x_j*w_j exp(2*pi*i*j*k/N)
;           
;    the power spectral density is defined at N/2+1 frequencies & given
;    by 
;              
;        P(0)  = Norm * abs(D_0)^2
;        P(fk) = Norm * [abs(D_k)^2 + abs(D_{N-k})^2], k=1,...,(N/2-1)
;        P(fc) = Norm * abs(D_{N/2})
;                    
;    where Norm is the normalization constant
;
;                      Norm = N^2/(total(w^2) * fs)
;
;    x is assumed to be uniformly sampled, i.e. x[i] corresponds to x
;    sampled at t = i/fs for i = 0,1,...,N.  If the x you want to pass
;    in has data gaps, create a new x, xu, with missing data at 
;    sample times specified by '!VALUES.F_NAN'
;
; Example: 
;
;  IDL> t = dindgen(1000)/4.0d ;4hz sampling rate
;  IDL> x = sin(2*!pi*t*1.25)
;  IDL> s = spectrogram(x, hanning(256), fs=4.0)                             
;  IDL> help, s
;   ** Structure <9bf538>, 6 tags, length=80816, data length=80816, refs=1:
;   PSD             DOUBLE    Array[77, 129]
;   FREQ            DOUBLE    Array[129]
;   TIME            FLOAT     Array[77]
;   N               LONG               256
;   NOVERLAP        LONG               128
;   FS              FLOAT           4.00000
;  IDL> psd1 = s.psd[0,*] ;get psd estimate at one time
;  IDL> df = s.fs/s.n
;  IDL> print, total(psd1)*df ;estimate total power in x at this time
;        0.50000000  ;units of [x]^2
;  IDL> contour, s.psd, s.time, s.freq, levels=[0.5*max(s.psd),max(s.psd)]
;
; Inputs:
;    X: Array[Nx] 1D Time series  
;    WIN: Array[nw] Windowing function (i.e. hanning(256))
;
;  Keywords:
;    FS:  Double  Sampling frequency.   
;
; Outputs:
;    S:   Structure
;      PSD:  Array[floor((Nx-Noverlap)/(Nw-Noverlap)), nw/2] 
;      Freq: Array[nw/2]
;      Time: Array[floor((Nx-Noverlap)/(Nw-Noverlap))]
;      N: Double Nw/2  
;     Noverlap:  Double Nw/2
;     Fs: Double  Sampling Frequency
;
; References:
;    Numerical Recipes in C, 13.4 Power Spectrum Estimation
;    http://holometer.fnal.gov/GH_FFT.pdf
;    http://www.exelisvis.com/docs/FFT.html
;
; Author:
;    Gregory S. Bowers
;   gsbowers@ucsc.edu
;   March 21, 2015
;-  

function spectrogram, x, w, fs=fs

  if ~keyword_set(fs) then fs = 1.0d

  Nx = n_elements(x)
  Nw = n_elements(w)
  Noverlap = Nw/2

  ;normalization for power spectral density
  Nrm = Nw^2/(total(w^2,/double)*fs)

  ;columns 
  ncol = floor((Nx-Noverlap)/(Nw-Noverlap))
  ;rows
  if (Nw mod 2) eq 0 then nrow = Nw/2+1 else nrow = (Nw+1)/2

  s = dindgen(ncol, nrow) 

  ;compute power spectral density psd 
  for k=0l, ncol-1 do begin
    i = indgen(Nw)+k*(Nw-Noverlap)
    c = fft(w*x(i), /double) ;idl FFT uses 1/N normalization

    posf = indgen(Nw/2-1)+1 ;indicies to positive frequencies 
    negf = Nw - posf        ;indicies to negative frequencies

    ;periodogram estimate of power spectrum 
    psd = [abs(c[0])^2.0d, $
           abs(c[posf])^2.0d + abs(c[negf])^2.0d, $
           abs(c[Nw/2])^2.0d] * Nrm

    s[k,*] = transpose(psd) 
  endfor

  ;calculate frequency  
  if Nw mod 2 eq 0 then $  
    f = [0.0d, (findgen((Nw-1)/2)+1), Nw/2]*fs/Nw $
  else $ 
    f = [0.0d, (findgen((Nw-1)/2)+1)]*fs/Nw
  
  ;calculate time
  t = findgen(ncol)*(Nw-Noverlap)/fs

  return, {psd:s, freq:f, time:t, n:nw, noverlap:noverlap, fs:fs}

end
