#!/bin/bash
# TODO: Restart sackd?
ctld_dbd_nodes=("dbd" "ctld")
compute_nodes=("node0" "node1" "node2")
nohup vagrant ssh dbd -c 'sudo systemctl restart slurmdbd'
nohup vagrant ssh ctld -c 'sudo systemctl restart slurmctld'
for n in ${nodes[@]}; do
	nohup vagrant ssh $n -c 'sudo systemctl restart slurmd' &
done
wait
