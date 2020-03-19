#!/bin/bash
# Check if the vm is running
state=$(vagrant global-status | awk '{if ($2=="centos7_mc" && $4=="running") print "running"}')
if [ "$state" != "running" ];then
    cd Vagrant && vagrant up
fi