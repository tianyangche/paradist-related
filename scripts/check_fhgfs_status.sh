#!/bin/bash

for i in 25 26 27 28 
#for i in 04 10 11 12 13 14 16 17 18 19 20 21 22 23 24 25 26 27 28 29 55 56 57 58 
#for i in 04 10 11 12 13 14 16 17 22 23 24 25 26 27 28 29 31 32 33 34 35 36 37 38
do
	ssh hec-$i hostname 
	ssh hec-$i ps -e | grep fhgfs
	ssh hec-$i ls /var/log | grep fhgfs
done
