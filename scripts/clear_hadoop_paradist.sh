#!/bin/bash
HADOOP_DIR=/mnt/common/tche/hadoop-1.1.2


echo "cleaning namenode  ..."
for host in `cat $HADOOP_DIR/conf/masters`
do
	ssh $host hostname
	ssh $host rm -rf /home/tche/fhgfs-mount/hadoop-$host
done

echo "cleaning datanode  ..."
for host in `cat $HADOOP_DIR/conf/slaves`
do
	ssh $host hostname
	ssh $host rm -rf /home/tche/fhgfs-mount/hadoop-$host
done


echo "now list ..."

for host in `cat $HADOOP_DIR/conf/masters`
do
	ssh $host hostname
	ssh $host ls /home/tche/fhgfs-mount
done

for host in `cat $HADOOP_DIR/conf/slaves`
do
	ssh $host hostname
	ssh $host ls /home/tche/fhgfs-mount
done

echo "deleting log files..."
	ssh hec-59 rm -rf /mnt/common/tche/hadoop-1.1.2/logs


