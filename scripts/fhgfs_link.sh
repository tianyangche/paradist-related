#!/bin/bash

for i in 25 26 27 28
do
	ssh hec-$i hostname
	ssh hec-$i sudo mkdir /etc/fhgfs
	ssh hec-$i sudo rm /etc/fhgfs/fhgfs-client.conf
	ssh hec-$i sudo ln -s /home/tche/etc/fhgfs/fhgfs-client.conf /etc/fhgfs/fhgfs-client.conf
done
