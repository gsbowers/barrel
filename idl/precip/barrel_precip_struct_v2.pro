function barrel_precip_struct_v2

;VERSION 2.0

;from version 1
;lat,long etc now array of 3 to store value at begin/middle/end of event
;added tmidpoint
;added dst
;added lstar
;added rbspa/b structs
;added rbsp_conj flag
;added exclude flag

;Defines and returns a structure for characterizing geomagnetic 
;activity and specturm of precipitation events

rpsp_data = {mlt:0.0d, l:0.0d, lstar:0.0d, data:dblarr(1000)}

ps = {$
 payload: "", $                        ;payload ID (e.g. 1U)
 trange:  dblarr(2)-1.d,$              ;source time intervals in Unix Epoch
 duration: dblarr(1)-1.d,$             ;duration of precipitation event
 bkgtrange: dblarr(2,2)-1.d, $         ;range of quiet background
 tdata: dblarr(3)-1.d,$                ;times within interval for data below
 latitude: dblarr(3)-1.d,$             ;average latitude
 longitude: dblarr(3)-1.d,$            ;average longitude
 altitude: dblarr(3)-1.d,$             ;average altitude
 MLT_Kp2_T89c: dblarr(3)-1.d,$         ;average magnetic local time kp2
 MLT_Kp6_T89c: dblarr(3)-1.d,$         ;average magnetic local time kp6
 l_kp2: dblarr(3)-1.d,$                ;l-shell value at kp2
 l_kp6: dblarr(3)-1.d,$                ;l-shell value at kp6
 l_star: dblarr(3)-1.d,$               ;l-star 
 maglat: dblarr(3)-1.d,$               ;aacgm_MLat in degrees 
 maglon: dblarr(3)-1.d,$               ;aacgm_MLon in degrees 
 dst: dblarr(3)-1.d,$                  ;dst index
 kp: {x:-1.d, y:-1d}, $                ;closet previous kp value
 kp_data: {x:dblarr(16), y:dblarr(16)}, $;noaa kp for previous and next day
 conj_lat: dblarr(8,3)-1.d, $          ;conjugate latitude 
 conj_lon: dblarr(8,3)-1.d, $          ;conjugate longitude
 SEP: -1.d, $                          ;SEP related flag
 Flare: -1.d, $                        ;flare related flag
 CRB: -1.d, $                          ;cosmic ray burst
 RBSPa: replicate(rpsp_data,3), $      ;vap probea/b, begin/middle/end
 RBSPb: replicate(rpsp_data,3), $      ;vap probea/b, begin/middle/end
 RBSP_conj: -1d,$                      ;conjunction with RBSP
 exclude: 0d, $                        ;exclusion flag 
 notes: '', $                          ;notes
 flag: -1d, $                          ;
 version: 'v2', $                      ;struct version
 payloads: strarr(20), $               ;other payloads up during this event
 npayloads: 1l, $
 data: dblarr(1000) $
}

return, ps

end
