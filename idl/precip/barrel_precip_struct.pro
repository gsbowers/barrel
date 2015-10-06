function barrel_precip_struct

;Defines and returns a structure for characterizing geomagnetic 
;activity and specturm of precipitation events

ps = {$
 payload: "", $                        ;payload ID (e.g. 1U)
 trange:  dblarr(2)-1.d,$              ;source time intervals in Unix Epoch
 duration: dblarr(1)-1.d,$             ;duration of precipitation event
 bkgtrange: dblarr(2,2)-1.d, $            ;range of quiet background
 latitude: -1.d,$                      ;average latitude
 longitude: -1.d,$                     ;average longitude
 altitude: -1.d,$                      ;average altitude
 MLT_Kp2_T89c: -1.d, $                 ;average magnetic local time kp2
 MLT_Kp6_T89c: -1.d, $                 ;average magnetic local time kp6
 l_kp2: -1.d,$                         ;l-shell value at kp2
 l_kp6: -1.d, $                        ;l-shell value at kp6
 maglat: -1.d,$                        ;aacgm_MLat in degrees 
 maglon: -1.d,$                        ;aacgm_MLon in degrees 
 kp: {x:-1.d, y:-1d}, $                ;closet previous kp value
 kp_data: {x:dblarr(16), y:dblarr(16)}, $;noaa kp for previous and next day
 conj_lat_kp2: -1.d, $                 ;conjugate latitude 
 conj_lon_kp2: -1.d, $                 ;conjugate longitude
 conj_lat_kp6: -1.d, $                 ;conjugate latitude 
 conj_lon_kp6: -1.d $                  ;conjugate longitude
}

return, ps

end
