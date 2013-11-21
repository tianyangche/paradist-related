#!/bin/bash

NODELIST=(25 26 27 28)
#NODELIST=(04 10 11 12 13 14 16 17 18 19 20 21 22 23 24 25 26 27 28 29 55 56 57 58)
#NODELIST=(04 10 11 12 13 14 16 17 22 23 24 25 26 27 28 29 31 32 33 34 35 36 37 38)
    for i in ${NODELIST[@]}
    do
        echo "HEC-$i:"
        ssh hec-$i cat /home/tche/etc/fhgfs/fhgfs-storage.conf | grep sysMgmtdHost 
    done

