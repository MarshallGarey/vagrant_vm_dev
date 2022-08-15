#!/bin/sh
#vagrant provision --debug | tee vagrant_provision.log
#vagrant provision | tee vagrant_provision.log

#vagrant provision dbd | tee vagrant_provision_dbd.log &
#vagrant provision ctld | tee vagrant_provision_ctld.log &
#vagrant provision node0 | tee vagrant_provision_node0.log &
#vagrant provision node1 | tee vagrant_provision_node1.log &

vagrant up --provision node0  | tee vagrant_provision_node0.log &
vagrant up --provision node1  | tee vagrant_provision_node1.log &
vagrant up --provision ctld  | tee vagrant_provision_node0.log &
vagrant up --provision dbd  | tee vagrant_provision_dbd.log &
wait
