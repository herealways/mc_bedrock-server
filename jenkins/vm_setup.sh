#!/bin/bash
# Create vagrant directory outside Jenkins workspace
if [ ! -d "$VAGRANT_PROJECT_PATH" ]; then
    mkdir -p $VAGRANT_PROJECT_PATH
fi

if [ ! -f "$VAGRANT_PROJECT_PATH/Vagrantfile" ]; then
    cp Vagrant/Vagrantfile $VAGRANT_PROJECT_PATH
fi

# Determine if Vagrantfile has changed
diff Vagrant/Vagrantfile $VAGRANT_PROJECT_PATH/Vagrantfile >/dev/null
if [ "$?" != 0 ]; then
    # \cp:  ignore alias cp="cp -i"
    \cp Vagrant/Vagrantfile $VAGRANT_PROJECT_PATH -f
fi

# Refresh state. Check if the vm is aborted
vm_id=$(vagrant global-status | awk '{if ($2=="mc_centos7") print $1}')
vagrant status $vm_id >/dev/null

# Check if the vm is running
state=$(vagrant global-status | awk '{if ($2=="mc_centos7") print $4}')
if [ "$state" != "running" ];then
    cd $VAGRANT_PROJECT_PATH && vagrant up
fi