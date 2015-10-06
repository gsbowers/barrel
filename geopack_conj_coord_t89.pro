;uses IDL geopack DLM at 
; http://ampere.jhuapl.edu/code/idl_geopack.html

;documentation of geopack DLM
; http://sprg.ssl.berkeley.edu/~windsound/new/themis/IDL%20Geopack%20DLM.pdf

;references needed to use above documentation
; http://geo.phys.spbu.ru/~tsyganenko/T96.html
; http://spdf.gsfc.nasa.gov/pub/models/old_models_from_nssdc/magnetospheric/tsyganenko/T89c.for
; http://www.rbsp-ect.lanl.gov/MagEphemDescription.php

;collection of tsygenenko model parameters!!!
; http://www.dartmouth.edu/~rdenton/magpar/

function geopack_conj_coord_t89, lat, lon, alt, t, kp

	YYYY = time_string(t, tformat='YYYY')
	MM = time_string(t, tformat='MM')
	DD = time_string(t, tformat='DD')
	hh = time_string(t, tformat='hh')
	mn = time_string(t, tformat='mm')
	
	year = UINT(YYYY)
	month = UINT(MM)
	day = UINT(DD)
	hour = UINT(hh)
	min = UINT(mn) 
	sec = 0

	geopack_recalc, year, month, day, hour, min, sec, /DATE, tilt=tilt

	SP_r = 1.0 + alt/6371. 
	SP_colat = (90.0 - lat) ;co-latitude
	SP_lon = lon ;longitude

	;convert spherical coordinates to geographical coordinates
	GEOPACK_SPHCAR, SP_r, SP_colat, SP_lon, $
	  SP_XGEO, SP_YGEO, SP_ZGEO, /to_rect, /DEGREE

	;convert Geographical coordinates to GSM
	GEOPACK_CONV_COORD, SP_XGEO, SP_YGEO, SP_ZGEO, $
    SP_XGSM, SP_YGSM, SP_ZGSM, /FROM_GEO, /TO_GSM

	;determine footpoint of GSM coordinates
	parmod = kp

	GEOPACK_TRACE, SP_XGSM, SP_YGSM, SP_ZGSM, -1, parmod, $
    CP_XGSM, CP_YGSM, CP_ZGSM, /IGRF, /T89

	;convert footpoint GSM coordinates to geographical coordinates
	GEOPACK_CONV_COORD, CP_XGSM, CP_YGSM, CP_ZGSM, $
    CP_XGEO, CP_YGEO, CP_ZGEO, /FROM_GSM, /TO_GEO

	GEOPACK_SPHCAR, CP_XGEO, CP_YGEO, CP_ZGEO, $
    CP_r, CP_colat, CP_lon, /TO_SPHERE, /DEGREE

	CP_lat = 90.0 - CP_colat 
	CP_lon = CP_lon - 360.0

	print, CP_lat, CP_lon

	return, [CP_lat, CP_lon]

end
