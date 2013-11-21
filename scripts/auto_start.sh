#!/bin/bash

rm storage manager

# start and config fhgfs
./startserver.sh config
./startserver.sh start
./check_fhgfs_status.sh
./set_check_size.sh
./look_check_size.sh


# start hadoop
hadoop namenode -format
start-all.sh



