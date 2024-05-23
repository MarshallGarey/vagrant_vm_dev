#!/bin/bash
# Sync etc to the ctld and bd nodes.
# The compute and login nodes will be configless.
ctl_dbd_nodes=("ctld" "dbd")
for n in ${ctl_dbd_nodes[@]}; do
	rsync -r tmpetc "vagrant@${n}:/home/vagrant"
	nohup vagrant ssh "${n}" -c '
	sudo rm -rf /usr/local/etc
	sudo mv ~/tmpetc /usr/local/etc
	sudo chown slurm:slurm /usr/local/etc
	sudo chown slurm:slurm /usr/local/etc/*
	sudo chmod 0600 /usr/local/etc/slurmdbd.conf
	sudo chmod 0600 /usr/local/etc/jwt_hs256.key
	sudo chmod 0600 /usr/local/etc/slurm.key
	' &
done
wait
