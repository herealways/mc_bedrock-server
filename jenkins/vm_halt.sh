#!/bin/bash
state=$(vagrant global-status | awk '{if ($2=="mc_centos7" && $4=="running") print "running"}')
if [ "$state" = "running" ];then
    cd $VAGRANT_PROJECT_PATH && vagrant halt
fi