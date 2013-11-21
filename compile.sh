#!/bin/bash

cd class/
rm -rf *
cd ..
rm *.jar

javac -classpath /mnt/common/tche/hadoop-1.1.2/hadoop-core-1.1.2.jar:/mnt/common/tche/hadoop-1.1.2/lib/commons-cli-1.2.jar -d class/ *.java
jar -cvf MyHadoop.jar -C class/ .

