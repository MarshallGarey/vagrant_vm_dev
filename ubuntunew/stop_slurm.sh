#!/bin/bash
ctld_dbd_nodes=("dbd" "ctld")
compute_nodes=("node0" "node1" "node2")
nohup vagrant ssh dbd -c 'sudo systemctl stop slurmdbd'
nohup vagrant ssh ctld -c 'sudo systemctl stop slurmctld'
for n in ${nodes[@]}; do
	nohup vagrant ssh $n -c 'sudo systemctl stop slurmd' &
done
wait
