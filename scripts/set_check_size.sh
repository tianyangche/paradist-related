#!/bin/bash

for i in 25 26 27 28
do
	 
	ssh hec-$i sudo fhgfs-ctl mode=setpattern numtargets=1 chunksize=16k /home/tche/fhgfs-mount
done
