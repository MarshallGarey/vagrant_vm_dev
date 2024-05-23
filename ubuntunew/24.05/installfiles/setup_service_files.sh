#!/bin/bash
# TODO: For sackd to work with configless, it needs to use SLURM_SACK_KEY to
# point to the alternate location (/run/slurm/conf/).
set -ex
n=$(hostname)

# (1) Move the service files to /etc/systemd/system
tmpdir="/tmp/setup_slurm"
mkdir -p "${tmpdir}"
cp ${HOME}/*.service "${tmpdir}"
cd "${tmpdir}"
sudo chown root:root *
sudo mv * "/etc/systemd/system"
# Update systemd since we replaced the service files.
sudo systemctl daemon-reload

# (2) Set options for the service files
if [[ "${n}" != "ctld" || "${n}" != "dbd" ]]; then
	tmpfile="${HOME}/etc_default_slurmd"
	echo SLURMD_OPTIONS=--conf-server=ctld:6817 > "${tmpfile}"
	sudo chown root:root "${tmpfile}"
	sudo mv "${tmpfile}" "/etc/default/slurmd"
fi

# (3) Ensure that the paths to the Slurm binaries (prefix/bin and prefix/sbin)
#     are in the global path (use /etc/profile.d/slurm)
tmpfile="${tmpdir}/slurm.sh"
slurm_profile="/etc/profile.d/slurm.sh"
echo 'PATH="${PATH}:/opt/slurm/24.05/bin:/opt/slurm/24.05/sbin"' > "${tmpfile}"
sudo chown root:root "${tmpfile}"
sudo mv "${tmpfile}" "${slurm_profile}"
rmdir "${tmpdir}"
