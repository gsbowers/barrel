#!/bin/bash

START=`ls *quicklook.png | head -1 | awk -F '[_]' '{print $2}'`
END=`ls *quicklook.png | tail -1 | awk -F '[_]' '{print $2}'`

DAYS=$(( ($(date --date=$END +%s) - $(date --date=$START +%s) )/(60*60*24) ))

echo $DAYS

for (( c=0; c <= $DAYS; c++ ))
do
	DATE=`date --date="$START +$c day" +%y%m%d`
	COUNT=`ls *$DATE*_lcurve.png 2> /dev/null |  wc -l`
	echo $DATE $COUNT
done
