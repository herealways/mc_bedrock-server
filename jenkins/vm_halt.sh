#!/bin/bash
if [ "$state" = "running" ];then
    cd $VAGRANT_PROJECT_PATH && vagrant halt
fi