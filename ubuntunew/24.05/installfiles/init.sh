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
	vagrant_home="/home/vagrant"
	edkey_name="id_ed25519"
	edkey_priv="/etc/ssh/ssh_host_${edkey_name}"
	edkey_pub="/etc/ssh/ssh_host_${edkey_name}.pub"
	local_edkey_priv="${vagrant_home}/.ssh/${edkey_name}"
	local_edkey_pub="${vagrant_home}/.ssh/${edkey_name}.pub"
	# Generate ssh keys on ctld that do not already exist
	vagrant ssh "ctld" -c '
		set -x
		hostname
		edkey_name="id_ed25519"
		cd "${HOME}/.ssh"
		found_key=$(find . -name ${edkey_name} | wc -l)
		echo ${found_key}
		if [[ ${found_key} == 0 ]]; then
			ssh-keygen -t ed25519 -N '' -f ${edkey_name}
		fi
		'

	# Copy back to host machine, then distribute to all VMs
	# This avoids needing a password, which I would need to use ssh-copy-id
	rsync "vagrant@ctld:${local_edkey_priv}" "${script_path}"
	rsync "vagrant@ctld:${local_edkey_pub}" "${script_path}"

	for n in ${all_nodes[@]}; do
		echo ${n}
		if [[ "${n}" != "ctld" ]]; then
			# Copy the ctld key to all other nodes
			rsync "${edkey_name}" "vagrant@${n}:${local_edkey_priv}"
			rsync "${edkey_name}.pub" "vagrant@${n}:${local_edkey_pub}"
		fi
		# Add the key to authorized keys
		nohup vagrant ssh "${n}" -c '
			set -x
			hostname
			pub_out="$(cat ~/.ssh/id_ed25519.pub)"
			echo ${pub_out}
			sshdir="${HOME}/.ssh"
			if [[ $(sudo grep "${pub_out}" "${sshdir}/authorized_keys" | wc -l) == 0 ]]; then
				sudo echo "${pub_out}" >> "${sshdir}/authorized_keys"
			fi
		' &
	done
	wait
	rm "${edkey_name}"
	rm "${edkey_name}.pub"

	# After distributing the key to all hosts, populate the known_hosts
	# files
	for n in ${all_nodes[@]}; do
		echo "${n}"
		nohup vagrant ssh "${n}" -c "
			ssh-keyscan -t dsa -4 -H ${all_nodes[@]} | sort -u - ~/.ssh/known_hosts > ~/.ssh/tmp_hosts
			mv ~/.ssh/tmp_hosts ~/.ssh/known_hosts
			sudo cp ~/.ssh/known_hosts /root/.ssh/known_hosts
		" &
	done
	wait
}


###############################################################################
# Script start
###############################################################################

all_nodes=("ctld" "dbd" "node0" "node1" "node2")
script_path="$(dirname -- "$( readlink -f -- "$0"; )";)"

set -x

# TODO: run vagrant ssh-config and add that to my .ssh/config file if it is
# not already there.

# * Copy example scripts from slurm/etc/ to tmpetc
get_scripts

# Add my ssh key to all the nodes
scp_ssh_key

# build_slurm also syncs the etc directory.
./build_slurm.sh
