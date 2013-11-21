#!/bin/bash
NODELIST=(25 26 27 28)
for i in 25 26 27 28 
do	
	ssh hec-$i sudo hostname 
	ssh hec-$i sudo fhgfs-ctl mode=getentryinfo /home/tche/fhgfs-mount
done
