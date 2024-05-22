#!/bin/bash

###############################################################################
# Functions
###############################################################################
function get_scripts()
{
	slurmsrc="${script_path}/../slurm"
	cp "${slurmsrc}/etc/burst_buffer.lua.example" "${script_path}/tmpetc/burst_buffer.lua"
	cp "${slurmsrc}/etc/cli_filter.lua.example" "${script_path}/tmpetc/cli_filter.lua"
	cp "${slurmsrc}/etc/job_submit.lua.example" "${script_path}/tmpetc/job_submit.lua"
}

function scp_ssh_key()
{
	set -e
	edkey_name="id_ed25519"
	edkey_priv="/etc/ssh/ssh_host_${edkey_name}"
	edkey_pub="/etc/ssh/ssh_host_${edkey_name}.pub"
	local_edkey_priv="/home/vagrant/.ssh/${edkey_name}"
	local_edkey_pub="/home/vagrant/.ssh/${edkey_name}.pub"
	# Generate ssh keys on ctld that do not already exist
	# TODO: Do the same thing for root as well as vagrant
	nohup vagrant ssh "ctld" -c '
		edkey_name="id_ed25519"
		cd /home/vagrant/.ssh
		found_key=$(find . -name ${edkey_name} | wc -l)
		echo ${found_key}
		if [[ ${found_key} == 0 ]]; then
			ssh-keygen -t ed25519 -N '' -f ${edkey_name}
			cat ${edkey_name}.pub >> authorized_keys
		fi
		'

	# Copy back to host machine, then distribute to all VMs
	# This avoids needing a password, which I would need to use ssh-copy-id
	vagrant scp "ctld:${local_edkey_priv}" "${script_path}"
	vagrant scp "ctld:${local_edkey_pub}" "${script_path}"
	pub_out="$(cat ${edkey_name}.pub)"

	for n in ${all_nodes[@]}; do
		if [[ "${n}" != "ctld" ]]; then
			# Copy the ctld key to all other nodes
			vagrant scp "${edkey_name}" "${n}:${local_edkey_priv}"
			vagrant scp "${edkey_name}.pub" "${n}:${local_edkey_pub}"
		fi
		nohup vagrant ssh "${n}" -c "
			cd /home/vagrant/.ssh
			echo ${pub_out}
			if [[ $(grep \"${pub_out}\" authorized_keys | wc -l) == 0 ]]; then
				echo ${pub_out} >> authorized_keys
			fi
			"
	done
	# TODO: Add to each node to each other's known_hosts file
}

function scp_etc()
{
	for n in ${ctl_dbd_nodes[@]}; do
		nohup vagrant ssh "${n}" -c 'cd /home/vagrant; mkdir -p tmpetc'
	done
	for f in $(ls tmpetc); do
		for n in ${ctl_dbd_nodes[@]}; do
			vagrant scp "${script_path}/tmpetc/${f}" "${n}:/home/vagrant/tmpetc"
		done
	done
}

function ensure_correct_slurm_permissions()
{
	# * Set the permissions of slurmdbd.conf and jwt key to 600
	for n in ${ctl_dbd_nodes[@]}; do
		nohup vagrant ssh "${n}" -c '
		cd /home/vagrant
		sudo rm -rf /usr/local/etc
		sudo mv ~/tmpetc /usr/local/etc
		sudo chown slurm:slurm /usr/local/etc
		sudo chown slurm:slurm /usr/local/etc/*
		sudo chmod 0600 /usr/local/etc/slurmdbd.conf
		sudo chmod 0600 /usr/local/etc/jwt_hs256.key
		'
	done
}

###############################################################################
# Script start
###############################################################################

ctl_dbd_nodes=("ctld" "dbd")
all_nodes=("ctld" "dbd" "node0" "node1" "node2")
script_path="$(dirname -- "$( readlink -f -- "$0"; )";)"

set -x

# TODO:
# * Copy example scripts from slurm/etc/ to tmpetc
#get_scripts

# Add my ssh key to all the nodes
#scp_ssh_key

# * vagrant scp the config files and scripts to user vagrant's home directory.
# /usr/local/etc on the destination ctld/dbd
# vagrant scp:
# Usage: vagrant scp <local_path> [vm_name]:<remote_path>
#        vagrant scp [vm_name]:<remote_path> <local_path>
# TODO: vagrant scp does not have -r, so we have to scp each file
# individually. It would be easier to add a ssh key from my native box to each
# vm and then do normal scp.
#
#scp_etc

#ensure_correct_slurm_permissions
./build_slurm.sh
