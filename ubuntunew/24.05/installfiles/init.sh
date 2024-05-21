#!/bin/bash

source init.conf
source script_common.sh

###############################################################################
# Functions
###############################################################################

function mkenvrc()
{
	envrc=".envrc"
	# envrc used to be a symlink. It isn't now. This rm will remove
	# the old symlink and ensure that it is a regular file.
	# This only matters for old setups that still have the symlink.
	if [ $(find -maxdepth 1 -name "${envrc}" | wc -l) -eq 1 ]
	then
		rm "${envrc}"
	fi
	echo '# .envrc
# This file is used by direnv (https://direnv.net/).
# direnv needs to be hooked into the shell: https://direnv.net/docs/hook.html
# Once direnv is hooked into the shell, it automatically sets environment
# variables listed in .envrc.
SYSCONF=$(pwd)
export PATH=$SYSCONF/bin:$SYSCONF/sbin:$PATH
export MANPATH=$SYSCONF/share/man:$MANPATH
export SACCT_FORMAT="cluster,jobid,jobname%20,state,exitcode,submit,start,end,elapsed,eligible"
export SPRIO_FORMAT="%.15i %9r %.10Y %.10S %.10A %.10B %.10F %.10J %.10P %.10Q %30T"
export SLURMRESTD=$(which slurmrestd)' > "${envrc}"
}

function mkslurmdbd_conf()
{
}

###############################################################################
# Script start
###############################################################################

# TODO:
# * Copy example scripts from slurm/etc/ to tmpetc
script_path="$(dirname -- "$( readlink -f -- "$0"; )";)"
slurmsrc="${script_path}/../slurm"
cp "${slurmsrc}/etc/burst_buffer.lua.example ${script_path}/tmpscripts/burst_buffer.lua"
cp "${slurmsrc}/etc/cli_filter.lua.example ${script_path}/tmpscripts/cli_filter.lua"
cp "${slurmsrc}/etc/job_submit.lua.example ${script_path}/tmpscripts/job_submit.lua"

# * vagrant scp the config files and scripts to /opt/slurm/etc on the
# destination ctld/dbd
# vagrant scp:
# Usage: vagrant scp <local_path> [vm_name]:<remote_path>
#        vagrant scp [vm_name]:<remote_path> <local_path>
#
vagrant scp "${script_path}/tmpetc/*" "ctld:/opt/slurm/etc/"
vagrant scp "${script_path}/tmpetc/*" "dbd:/opt/slurm/etc/"
# * Change the permissions of slurmdbd.conf to 600
nohup vagrant ssh ctld -c 'chmod /opt/slurm/etc/slurmdbd.conf 0600'
nohup vagrant ssh dbd -c 'chmod /opt/slurm/etc/slurmdbd.conf 0600'
# TODO: Create a jwt key and set permissions to 600

# * Build Slurm on the ctld host:
nohup vagrant ssh ctld -c '
cd /opt/slurm/24.05
mkdir -p build
cd build
../../slurm/configure --enable-developer --disable-optimizations --enable-memory-leak-debug
make.py
'
# * scp the resulting Slurm binaries and libraries
#     (/usr/local/bin and /usr/local/lib) to dbd and all nodes
# * vagrant scp the systemd service files (slurmd.service, slurmctld.service,
#   slurmdbd.service, sackd.service, slurmrestd.service) to the appropriate
#   nodes.
#   - For now, nodes 0 and 1 are compute nodes and node 2 is a login node.
# * On each compute and login node, set SLURMD_OPTIONS in /etc/default/slurmd
#   to use the --conf-server option.
