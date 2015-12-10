function irbem_lstar, t, alt, lat, lon, kp 

lib_name = '/home/gsbowers/irbem/irbem-code/source/onera_desp_lib_linux_x86_64.so'

ntime_max = -1l
result = call_external(lib_name, 'get_irbem_ntime_max_', ntime_max, /f_value)

;INPUTS ##########

;ntime: long integer number of time in arrays (max allowed is NTIME_MAX)
ntime = long(n_elements(t))

if ntime gt ntime_max then message, 'n_elements(t) must be less than ', ntime_max

;kext: long integer to select external magnetic field
;  4 = Tsyganenko [1989c] (uses 0≤Kp≤9 - Valid for rGEO≤70. Re) 
kext = 4l

;options: array(5) of long integer to set some control options on computed values
options = lonarr(5)

;    options(1st element):  0 - don't compute L* or Φ ;  1 - compute L*; 2- compute Φ
options(0) = 0l
;    options(2nd element): 0 - initialize IGRF field once per year (year.5);  n - n is the  frequency (in days) starting on January 1st of each year (i.e. if options(2nd element)=15 then IGRF will be updated on the following days of the year: 1, 15, 30, 45 ...)
options(1) = 1l
;    options(3rd element): resolution to compute L* (0 to 9) where 0 is the recomended value to ensure a good ratio precision/computation time (i.e. an error of ~2% at L=6). The higher the value the better will be the precision, the longer will be the computing time. Generally there is not much improvement for values larger than 4. Note that this parameter defines the integration step (θ) along the field line such as dθ=(π)/(720*[options(3rd element)+1])
options(2) = 0l
;    options(4th element): resolution to compute L* (0 to 9). The higher the value the better will be the precision, the longer will be the computing time. It is recommended to use 0 (usually sufficient) unless L* is not computed on a LEO orbit. For LEO orbit higher values are recommended. Note that this parameter defines the integration step (φ) along the drift shell such as dφ=(2π)/(25*[options(4th element)+1])
options(3) = 0l
;    options(5th element): allows to select an internal magnetic field model (default is set to IGRF)
options(4) = 0l 

;sysaxes, sysaxesIN, and sysaxesOUT: long integer to define which coordinate system is provided in
;0: GDZ (alti, lati, East longi - km,deg.,deg)
sysaxes = 0l

;iyear, iyr or iyearsat: array(NTIME_MAX) of long integer year when measurements are given. 
;idoy: array(NTIME_MAX) of long integer doy when measurements are given
;UT or secs: array(NTIME_MAX) of double, UT in seconds
iyear = long(time_string(t, tformat='YYYY'))
idoy = long(time_string(t, tformat='DOY'))
UT = t - gettime(time_string(t, tformat='YYYY-MM-DD'))

; x1: array(NTIME_MAX) of double, first coordinate according to sysaxes. If sysaxes is 0 then altitude has to be in km otherwise use dimensionless variables (in Re)
x1 = double(alt)

;x2: array(NTIME_MAX) of double, second coordinate according to sysaxes. If sysaxes is 0 then latitude has to be in degrees otherwise use dimensionless variables (in Re)
x2 = double(lat)

;x3: array(NTIME_MAX) of double, third coordinate according to sysaxes. If sysaxes is 0 then longitude has to be in degrees otherwise use dimensionless variables (in Re). 
x3 = double(lon)
;if x3 gt 180 then x3 = 180.0d - x3

; maginput: array (25,NTIME_MAX) of double to specify magnetic fields inputs such as:
maginput = dblarr(25, ntime)

;    maginput(1st element,*) =Kp: value of Kp as in OMNI2 files but has to be double instead of integer type. (NOTE, consistent with OMNI2, this is Kp*10, and it is in the range 0 to 90) 
maginput(0,*) = double(kp)*10.0d


;OUTPUTS ##########

;Lm: L McIlwain (array(NTIME_MAX,NALPHA_MAX) of double)
;lm = -1.d
lm = dblarr(ntime)-1.d

;Lstar or Φ : L Roederer  or Φ=2π*Bo*/Lstar [nT Re2] (array(NTIME_MAX,NALPHA_MAX) of double)
;lstar = -1.d
lstar = dblarr(ntime)-1.d

;Blocal: magnitude of magnetic field at point (array(NTIME_MAX,NALPHA_MAX) of double) - [nT]
;blocal = -1.d
blocal = dblarr(ntime)-1.d

;Bmin: magnitude of magnetic field at equator (array(NTIME_MAX,NALPHA_MAX) of double) - [nT]
;bmin = -1.d
bmin = dblarr(ntime)-1.d

;XJ: I, related to second adiabatic invariant (array(NTIME_MAX,NALPHA_MAX) of double) - [Re]
;xj = -1.d
xj = dblarr(ntime)-1.d

;MLT: magnetic local time in hours, (array(NTIME_MAX,NALPHA_MAX) of double) - [hour]
;mlt = -1.d
mlt = dblarr(ntime)-1.d

result = call_external(lib_name, 'make_lstar_', ntime,kext,options,sysaxes,iyear,idoy,ut, x1,x2,x3, maginput, lm,lstar,blocal,bmin,xj,mlt, /f_value)


return, {mlt:mlt, lm:abs(lm)}

end
