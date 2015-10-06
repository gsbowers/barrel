pro barrel_make_fspc, probe

	data = string(format='(%"brl%s_FSPC1 brl%s_FSPC2 brl%s_FSPC3 brl%s_FSPC4")', probe, probe, probe, probe)

	labels = strsplit(data, 'brl'+probe+'_ ', /EXTRACT)
	labels[0] = 'FSPC1'
	
	store_data, string(format='(%"brl%s_FSPC")', probe), data=data, limit={labflag:1, labels:labels}

end
