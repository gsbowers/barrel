#! /bin/bash

for lcurve in *lcurve*.png
do 
	prefix=`echo $lcurve | cut -d'_' -f 1,2,3,4`
	spectra=$prefix'_spectra.png'
	output=$prefix'_quicklook.png'
	convert $lcurve $spectra +append $output
	echo $output
	
done
