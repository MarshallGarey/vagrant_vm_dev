#!/bin/sh
#vagrant provision --debug | tee vagrant_provision.log
#vagrant provision | tee vagrant_provision.log

#vagrant provision dbd | tee vagrant_provision_dbd.log &
#vagrant provision ctld | tee vagrant_provision_ctld.log &
#vagrant provision node0 | tee vagrant_provision_node0.log &
#vagrant provision node1 | tee vagrant_provision_node1.log &
#vagrant provision node2 | tee vagrant_provision_node2.log &

vagrant up --provision --debug node0  | tee vagrant_provision_node0.log &
vagrant up --provision --debug node1  | tee vagrant_provision_node1.log &
vagrant up --provision --debug node2  | tee vagrant_provision_node2.log &
vagrant up --provision --debug ctld  | tee vagrant_provision_ctld.log &
vagrant up --provision --debug dbd  | tee vagrant_provision_dbd.log &
wait
# The nfs mount requires a restart for some reason
vagrant halt
vagrant up
