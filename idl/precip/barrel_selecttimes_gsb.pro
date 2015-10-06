pro barrel_selecttimes_gsb,trange,payload,color=color
if not keyword_set(color) then color=115

;select a subset
ctime, t, npoints=2, prompt="Use cursor to select a begin time and an end time", $
	hours=hour, minutes=minutes, seconds=seconds, days=days, silent=silent
if n_elements(t) ne 2 then return

if t[0] gt t[1] then t=[t[1],t[0]]
trange = t

;overplot selected interval
get_data, string(format='(%"brl%s_FSPC1")', payload), data=fspc
;get_data, string(format='(%"brl%s_HKPG_T0_Scint")', payload), data=fspc
w = where(fspc.x ge t[0] and fspc.x le t[1])
tplot_panel, fspc.x(w), fspc.y(w), panel=1, color=color

timebar, trange

end
