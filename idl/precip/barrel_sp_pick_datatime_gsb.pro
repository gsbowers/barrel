;+
;NAME: barrel_sp_pick_datatime_gsb.pro
;
;DESCRIPTION: Pick start and stop times for spectral accumulation and
;background 

;
;REQUIRED INPUTS:
;ss                spectrum structure
;startdatetime     start time for plot from which we will pick source
;                  and background times, format yyyy-mm-dd/hh:mm:ss
;duration          duration in hours to look, starting at startdatetime
;payload           payload ID, with format, e.g., '1G'
;bkgmethod         1=select bkg intervals from data stream
;                  2=use bkg model from U. of Washington       
;
;OPTIONAL INPUTS:
;lcband            which FSPC band to plot during selection (default 1)
;uselog            plot FSPC data on a log scale (default 0)
;level             data CDF level (default 'l2')
;version           data CDF version for barrel_load_data.  If not
;                  specified, use that routine's default
;starttimes,endtimes,startbkg,endbkg:
;   start and end times (string format or unix epoch) for source
;   and background intervals (if not to be selected graphically)
;
;medticks,slowticks   Show vertical dotted lines at the start and
;                     and of medium, slow spectra (for use only
;                     when zoomed in to small times!
;
;OUTPUTS: No direct outputs, but the spectrum structure ss gets
;updated with trange and bkgtrange (primary purpose of this routine),
;also: payload,askdate, askduration, bkgmethod
;
;CALLS: barrel_load_data, barrel_selecttimes
;
;NOTES: 
;
;STATUS: 
;
;TO BE ADDED:
;
;REVISION HISTORY:
;Version 3.0 DMS 9/9/13
;   Most recent changes from v2.9:
;   remove passing x start and stop values to barrel_selecttimes 
;KY 8/28/13 'brl???_' -> 'brl' and '_LC' -> '_FSPC' (update tplot
;   variable names)
;9/30/13 -- remove "dobkg"; whether background intervals are
;   selected should automatically follow bkgmethod.
;10/1/13 -- put in option for already having specified the time ranges
;           by hand. (start/end times/bkgs)
;10/25/13 -- add provision for start/end times entered by hand to be
;           already in unix epoch (as from a prev. run)
;10/29/13 - Add plot of altitude to assist in background selection
;11/12/13 - Add option for vertical ticks for medium and slow spectra
;11/12/13 - Add default "no update" for reading FSPC data
;2/10/15 DMS - collect altitude using correct source time interval (average)
;3/5/15 DMS - cull out "NaNs" from altitude data before averaging
;8/20/15 DMS - fix bug wherein 3/5 fix only applied to
;              screen-selected, not predetermined time intervals.
;              This reorders operations somewhat 
;9/22/15 GSB - line 185: yrange=minmax(gpsalt.y) to yrange=minmax(gpsalt.y(w)).  Now range on alt is set for selected interval

pro barrel_sp_pick_datatime_gsb,ss,startdatetime,duration,payload,bkgmethod, $
  lcband=lcband, uselog=uselog, level=level, version=versoin,$
	starttimes=starttimes, endtimes=endtimes, startbkgs=startbkgs,$
	endbkgs=endbkgs,mticks=mticks,sticks=sticks,altitude=altitude

if not keyword_set(level) then level='l2'
if not keyword_set(lcband) then lcband=1
if not keyword_set(uselog) then uselog=0

payload = strupcase(payload)   ;just in case it was entered lowercase
ss.payload = payload
ss.askdate = startdatetime
ss.askduration = duration
ss.bkgmethod = bkgmethod

;This time range should include what you will use for src and bkg, ideally
;startdatetime format 
;duration is in hours

;timespan already set
;timespan,startdatetime,duration,/hour 

;If the times have already been specified by hand, use them and go: 
if keyword_set(starttimes) then begin
    typ = size(starttimes[0],/type)
    if typ EQ 7 then begin
       for i=0,ss.numsrc-1 do ss.trange[0,i] = str2time(starttimes[i],informat='YMDhms')
       for i=0,ss.numsrc-1 do ss.trange[1,i] = str2time(endtimes[i],informat='YMDhms')
    endif else begin
       for i=0,ss.numsrc-1 do ss.trange[0,i] = starttimes[i]
       for i=0,ss.numsrc-1 do ss.trange[1,i] = endtimes[i]
    endelse

    if ss.bkgmethod eq 1 then begin
       typ = size(startbkgs[0],/type)
       if typ EQ 7 then begin
          for i=0,ss.numbkg-1 do ss.bkgtrange[0,i] = str2time(startbkgs[i],informat='YMDhms')
          for i=0,ss.numbkg-1 do ss.bkgtrange[1,i] = str2time(endbkgs[i],informat='YMDhms')
       endif 
			 if typ eq 5 then begin
          for i=0,ss.numbkg-1 do ss.bkgtrange[0,i] = startbkgs[i]
          for i=0,ss.numbkg-1 do ss.bkgtrange[1,i] = endbkgs[i]
			 endif else begin
          for i=0,ss.numsrc-1 do ss.bkgtrange[0,i] = startbkgs[i]
          for i=0,ss.numsrc-1 do ss.bkgtrange[1,i] = endbkgs[i]
       endelse
    endif
endif  else begin

for ns=0,ss.numsrc-1 do begin

  ;Select a subset of the data graphically:
  print,'Click at the left and right of a time range for spectral interval ',ns+1
  ;barrel_selecttimes,hourtimes,lc.y, datause, ndatause, color=3
  barrel_selecttimes_gsb ,ssrange, payload, color=115

  ;Fill in the appropriate part of the structure:
  ss.trange[*,ns] = ssrange

end

if ss.bkgmethod eq 1 then begin  

  for nb=0,ss.numbkg-1 do begin

    ;Select a subset of the data graphically:
    print,'Click at the left and right of a time range for background interval ',nb+1
    ;barrel_selecttimes,hourtimes,lc.y, datause, ndatause, color=6
  	barrel_selecttimes_gsb, bkgrange, payload, color=6

    ;Fill in the appropriate part of the structure:
    ss.bkgtrange[*,nb] = bkgrange

  end 
endif

endelse

;Get altitude data;
get_data, string(format='(%"brl%s_GPS_Alt")', payload), data=gpsalt
altsum=0.d
altnorm=0.d
if not keyword_set(altitude) then begin 
      ;get altitude
      for i=0,ss.numsrc-1 do begin
        w=where(gpsalt.x ge ss.trange[0,i] and gpsalt.x le ss.trange[1,i],nw)
        ;patch for NaN values possible on day boundary (?):
        vals = gpsalt.y[w]
        wbad = where(finite(vals) eq 0,nbad)
        if nbad gt 0 then begin
           wfin=where(finite(vals))
           altave = average( vals[wfin] )
           vals[wbad] = altave
        endif  
        altsum += total(vals)
        altnorm += 1.d * nw
      endfor
      altitude = altsum/altnorm
endif     
  
altitude = altsum/altnorm
print,'ALTITUDE! ' , altitude


end

