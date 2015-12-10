pro plot_campaign2

	campaign = 2

	make_espectra, campaign=campaign

	make_alt_coverage, campaign=campaign
	make_alt_spectra, campaign=campaign

	make_mlt_coverage, campaign=campaign
	make_mlt_spectra, campaign=campaign

	make_l_coverage, campaign=campaign
	make_l_spectra, campaign=campaign

	addtitle = '2014'

	plot_espectra, addtitle=addtitle
	write_png, './figs/campaign2/efold_dist.png', tvrd(/true)

	plot_alt_coverage, addtitle=addtitle
	write_png, './figs/campaign2/alt_coverage.png', tvrd(/true)
	plot_alt_spectra, addtitle=addtitle
	write_png, './figs/campaign2/alt_spectra.png', tvrd(/true)

	plot_mlt_coverage, addtitle=addtitle, /shift
	write_png, './figs/campaign2/mlt_coverage.png', tvrd(/true)
	plot_mlt_spectra, addtitle=addtitle, /shift
	write_png, './figs/campaign2/mlt_spectra.png', tvrd(/true)

	plot_l_coverage, addtitle=addtitle
	write_png, './figs/campaign2/l_coverage.png', tvrd(/true)
	plot_l_spectra, addtitle=addtitle
	write_png, './figs/campaign2/l_spectra.png', tvrd(/true)

end
