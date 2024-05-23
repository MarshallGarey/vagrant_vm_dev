#!/bin/bash
set -ex
n=$(hostname)

tmpdir="/tmp/servicefiles"
mkdir -p "${tmpdir}"
cp ${HOME}/*.service "${tmpdir}"
cd "${tmpdir}"
sudo chown root:root *
sudo mv * "/etc/systemd/system"
if [[ "${n}" != "ctld" || "${n}" != "dbd" ]]; then
	tmpfile="${HOME}/etc_default_slurmd"
	echo SLURMD_OPTIONS=--conf-server=ctld:6817 > "${tmpfile}"
	sudo chown root:root "${tmpfile}"
	sudo mv "${tmpfile}" "/etc/default/slurmd"
fi
rmdir "${tmpdir}"
