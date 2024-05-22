#!/bin/bash
#
# * Update the conf files on ctld and dbd
# * Build Slurm on the ctld host to a shared file location.
# * But set the conf files to be in a local location: /usr/local/etc
# * Share the systemd service files (slurmd.service, slurmctld.service,
#   slurmdbd.service, sackd.service, slurmrestd.service) to the appropriate
#   nodes.
#   - For now, nodes 0 and 1 are compute nodes and node 2 is a login node.
# * On each compute and login node, set SLURMD_OPTIONS in /etc/default/slurmd
#   to use the --conf-server option.
./sync_etc.sh

nohup vagrant ssh ctld -c '
# BUILD:
servicedir="/etc/systemd/system"
prefix="/opt/slurm/24.05"
clusternodes=("node0" "node1" "node2" "ctld" "dbd")
compute_login_nodes=("node0" "node1" "node2")

cd /opt/slurm
sudo mkdir -p build
sudo chown vagrant:vagrant build
cd build
../24.05/slurm/configure --prefix="${prefix}" --enable-developer --disable-optimizations --enable-memory-leak-debug --with-systemdsystemunitdir="${prefix}" --sysconfdir=/usr/local/etc
sudo make.py --with-extra etc

# Distribute the service files
sudo cp "${prefix}/*.service" "${HOME}"
sudo chown vagrant:vagrant "${HOME}"/*

rsync "${HOME}/slurmdbd.service" "vagrant@dbd:${HOME}/slurmdbd.service"
for n in ${clusternodes[@]}; do
	rsync "${HOME}/sackd.service" "vagrant@${n}:${HOME}"
	rsync "${HOME}/slurmd.service" "vagrant@${n}:${HOME}"
	rsync "${HOME}/slurmrestd.service" "vagrant@${n}:${HOME}"
	ssh "vagrant@${n}" << EOF
		cd "${HOME}"
		sudo chown root:root "${HOME}:*.service"
		sudo mv "${HOME}:*.service" "/etc/systemd/system"
		if [[ "${n}" != "ctld" || "${n}" != "dbd" ]]; then
			tmpfile="${HOME}/etc_default_slurmd"
			echo SLURMD_OPTIONS=--conf-server=ctld:6817 > "${tmpfile}"
			sudo chown root:root "${tmpfile}"
			sudo mv "${tmpfile}" "/etc/default/slurmd"
		fi
	EOF
done
'
