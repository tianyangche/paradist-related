#!/bin/bash
sudo su -c "sync; echo 3 >/proc/sys/vm/drop_caches"
