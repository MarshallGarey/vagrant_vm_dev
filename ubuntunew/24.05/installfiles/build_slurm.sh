#!/bin/bash
#
# * Build Slurm on the ctld host,
# * scp the resulting Slurm binaries and libraries
#     (/usr/local/bin and /usr/local/lib) to dbd and all nodes
# * vagrant scp the systemd service files (slurmd.service, slurmctld.service,
#   slurmdbd.service, sackd.service, slurmrestd.service) to the appropriate
#   nodes.
#   - For now, nodes 0 and 1 are compute nodes and node 2 is a login node.
# * On each compute and login node, set SLURMD_OPTIONS in /etc/default/slurmd
#   to use the --conf-server option.
nohup vagrant ssh ctld -c '
# BUILD:
cd /opt/slurm
sudo mkdir -p build
sudo chown vagrant:vagrant build
cd build
#../24.05/slurm/configure --enable-developer --disable-optimizations --enable-memory-leak-debug --with-systemdsystemunitdir=/etc/systemd/system
#sudo make.py --with-extra etc
# Distribute the resulting libraries, binaries, and service files to other nodes
clusternodes=("node0" "node1" "node2" "dbd")
servicedir="/etc/systemd/system"
for n in ${clusternodes[@]}; do
	scp -r /usr/local/lib "vagrant@${n}:/usr/local/"
	scp -r /usr/local/bin "vagrant@${n}:/usr/local/"
	scp -r /usr/local/sbin "vagrant@${n}:/usr/local/"
	scp "${servicedir}/sackd.service" "vagrant@ctld:${servicedir}"
done
sudo scp "${servicedir}/slurmdbd.service" "vagrant@dbd:${servicedir}/slurmdbd.service"
compute_login_nodes=("node0" "node1" "node2")
for n in ${compute_login_nodes[@]}; do
	scp "${servicedir}/slurmd.service" "vagrant@${n}:${servicedir}/slurmd.service"
	#sudo echo SLURMD_OPTIONS=--conf-server=ctld:6817 > /etc/default/slurmd
done
'
