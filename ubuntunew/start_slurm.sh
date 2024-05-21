#!/bin/bash
nodes=("node0" "node1")
nohup vagrant ssh dbd -c 'slurmdbd' &
nohup vagrant ssh ctld -c 'slurmctld' &
for n in $nodes
do
	nohup vagrant ssh $n -c 'slurmd' &
done
wait
