#! /bin/bash
#hadoop fs -rmr in out
#hadoop fs -mkdir in
#hadoop fs -copyFromLocal in/input4 in
NODES=(55 56 57 58)
for node in ${NODES[@]}
do
    echo ssh hec-$node hadoop jar MyHadoop.jar org.myorg.MyCat hdfs://hec-59/user/tche/in/input4  &
done
wait
