;+  return a background x-ray model
;
; INPUT: energylist is a list of positive energies (keV)
;        alt is altitude in km (25<alt<40)
;
; OUTPUT: returns a list of counts/s/kev corresponding to energylist
;         returns -1 for input out of range
;
; METHOD: based on an empirical model derived from BARREL flights
;         model is ok between 30 and 8000 keV
;         background is primarily two power law components
;            these turn over at low energy
;            the 511 line contributes several features
;         prevent underflows by avoiding exp(-huge number)
;
; CALLS: none
;
; EXAMPLE: result = barrel_make_model_bkg([10,20,50,100],33.2)
;            calculates bkgd differential count rate at the
;            4 specified energies for a detector at mag lat
;
; FUTURE WORK:
;
;COMMENT
; model ignores solar cycle changes of cosmic ray and associated
;   background X-ray intensity
; real background for < 60keV is to some extent affected by detector
;   temperature effects that are not captured in the model 
;
; REVISION HISTORY:
; works, tested mm/18 Dec 2012
; version 2, updated LZ/ May 28th, 2013
;   improved constants and latitude function
; version 3, updated LZ+MM/ 28Jul2015
;   removed latitude dependence; added two humps
;-

function barrel_make_model_bkg, energylist, alt

  if min(energylist) le 0 then return, -1
  if (alt lt 25 or alt gt 40) then return, -1
  n = n_elements(energylist)

  altfactor = exp(-alt/8.5)
  c1 = 4.660e7*(altfactor + 0.03091)
  c2 = 340.8*(altfactor + 0.05344)
  c3 = 3.789*(altfactor +0.03685)
  c4 = 565.5 - 8.648*alt
  c5 = 15.95 - 0.1489*alt

  powerlaw1 = c1*(energylist)^(-2.75)
  powerlaw2 = c2*(energylist)^(-0.92)

  turnover1 = fltarr(n)+1.
  good = where(energylist lt 900,cnt)
  if cnt gt 0 then $
    turnover1[good] = (1 + c5*exp(-energylist[good]/45.5))

  turnover2 = fltarr(n)+1.
  good = where(energylist lt 250,cnt)
  if cnt gt 0 then $
    turnover2[good] = (1 + c4*exp(-energylist[good]/9.39))

  area511=fltarr(n)
  good = where(400 lt energylist and energylist lt 600,cnt)
  if cnt gt 0 then $
    area511[good] += exp(-((energylist[good]-511)/20)^2/2)
  good = where(energylist lt 850,cnt)
  if cnt gt 0 then $
    area511[good] += 0.18 * exp(-((energylist[good]-445.47)/60.)^2/2)
  good = where(200 lt energylist and energylist lt 400,cnt)
  if cnt gt 0 then $
    area511[good] += 0.13 * exp(-((energylist[good]-312.)/20.)^2/2)

  bump1 = fltarr(n)
  good = where(energylist lt 70,cnt)
  if cnt gt 0 then $
    bump1[good] = 0.55*exp(-((energylist[good]-35.5)/5.1)^2/2)

  bump2 = fltarr(n)
  good = where(energylist lt 50,cnt)
  if cnt gt 0 then $
    bump2[good] = -0.32*exp(-((energylist[good]-25.6)/3.55)^2/2)

  return,(powerlaw1+powerlaw2)/(turnover1*turnover2) + c3*area511 + $
      bump1 + bump2
end
