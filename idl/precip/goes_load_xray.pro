pro goes_load_xray, probe=probe
	
	if ~keyword_set(probe) then probe='15'

	goes_load_data, datatype='xrs', probes=probe
	var = string(f='(%"g%s_xrs_avg")', probe)
	options, var, ytitle='GOES 15!C[W/m^2]', yrange=[1e-9,1e-2], ystyle=1, ylog=1 
	
	store_data, 'Xclass', data={x:[0d, 1d10],y:[1e-4,1e-4]}, dlimit={labflag:0, labels:'X', ylog:1} 

	store_data, 'Mclass', data={x:[0d, 1d10],y:[1e-5,1e-5]}, dlimit={labflag:0, labels:'M', ylog:1} 

	store_data, 'Cclass', data={x:[0d, 1d10],y:[1e-6,1e-6]}, dlimit={labflag:0, labels:'C', ylog:1} 

	store_data, 'Bclass', data={x:[0d, 1d10],y:[1e-7,1e-7]}, dlimit={labflag:0, labels:'B', ylog:1} 

	store_data, 'Aclass', data={x:[0d, 1d10],y:[1e-8,1e-8]}, dlimit={labflag:0, labels:'A', ylog:1, ytickv:1e-8, ytickname:'A', yaxis:1} 

	store_data, 'GOES_xrs', data=[var, 'Xclass', 'Mclass', 'Cclass', 'Bclass', 'Aclass'], dlimit={ylog:1,yrange:[1e-9,1e-2], ystyle:1} 


end
