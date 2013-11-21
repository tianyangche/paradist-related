#!/bin/bash

MANAGERLIST=(25 26 27 28) 
#MANAGERLIST=(04 10 11 12 13 14 16 17 18 19 20 21 22 23 24 25 26 27 28 29 55 56 57 58 59)
#MANAGERLIST=(04 10 11 12 13 14 16 17 22 23 24 25 26 27 28 29 31 32 33 34 35 36 37 38)
USERNAME=tche

    echo "Checking hadoop status ..."
    for i in ${MANAGERLIST[@]} ${STORAGELIST[@]}
    do
	ssh hec-$i sudo hostname 
	ssh hec-$i sudo jps
    done
