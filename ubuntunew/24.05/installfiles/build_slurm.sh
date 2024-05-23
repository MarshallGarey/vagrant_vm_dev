#!/bin/bash
#
# * Sync the etc directory to the ctld and dbd nodes
# * Build Slurm on the ctld host. Configure the installation to a shared file
#   location, but but the conf files to a local location (/usr/local/etc).
# * Share the systemd service files (slurmd.service, slurmctld.service,
#   slurmdbd.service, sackd.service, slurmrestd.service) to the appropriate
#   nodes.
#   - For now, nodes 0 and 1 are compute nodes and node 2 is a login node.
# * On each compute and login node, set SLURMD_OPTIONS in /etc/default/slurmd
#   to use the --conf-server option.

./sync_etc.sh
set -ex
rsync setup_service_files.sh "vagrant@ctld:~/"
vagrant ssh ctld -c '
set -ex
# BUILD:
prefix="/opt/slurm/24.05"
service_confdir="${prefix}/service"
servicedir="/etc/systemd/system"
clusternodes=("node0" "node1" "node2" "ctld" "dbd")
compute_login_nodes=("node0" "node1" "node2")

cd /opt/slurm
sudo mkdir -p build
sudo chown vagrant:vagrant build
cd build
mkdir -p "${service_confdir}"
../24.05/slurm/configure --prefix="${prefix}" --enable-developer --disable-optimizations --enable-memory-leak-debug --with-systemdsystemunitdir="${service_confdir}" --sysconfdir=/usr/local/etc
sudo make.py --with-extra etc

# Distribute the service files
cd "${service_confdir}"
for f in $(ls "${service_confdir}"); do cp "${f}" "${HOME}"; done
cd "${HOME}"
ls -l
sudo chown vagrant:vagrant "${HOME}"/*
ls -l

rsync "${HOME}/slurmdbd.service" "vagrant@dbd:${HOME}"

for n in ${clusternodes[@]}; do
	rsync "${HOME}/sackd.service" "vagrant@${n}:${HOME}"
	rsync "${HOME}/slurmd.service" "vagrant@${n}:${HOME}"
	rsync "${HOME}/slurmrestd.service" "vagrant@${n}:${HOME}"
	if [[ "${n}" == "ctld" ]]; then
		"${HOME}/setup_service_files.sh"
	else
		ssh "${n}" bash -s < "${HOME}/setup_service_files.sh"
	fi
done
'
