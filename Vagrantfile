# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
	config.vm.box = "generic/centos8"
	# Default hardware setup
	config.vm.provider :libvirt do |libvirt|
		libvirt.cpus = 40
		libvirt.cputopology :sockets => '4', :cores => '10', :threads => '1'
		libvirt.memory = 2048
	end

	# Pull over some useful files
	config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
#config.vm.provision "file", source: "~/.bashrc", destination: ".bashrc"
	config.vm.provision "file", source: "~/.vimrc", destination: ".vimrc"
	config.vm.provision "file", source: "~/.viminfo", destination: ".viminfo"

	# Directories (need the full path):
	# copying the .vim/ directory is being slow
#config.vm.provision "file", source: "~/.vim", destination: "/tmp/.vim"
#config.vm.provision "file", source: "~/tools", destination: "/tmp/tools"

	config.vm.provision "shell", inline: <<-SHELL
		# Move directories
#		rm -rf /home/vagrant/.vim
#		mv /tmp/.vim /home/vagrant/.vim
#		rm -rf /home/vagrant/tools
#		mv /tmp/tools /home/vagrant/tools

		# compile whereami.c in tools
		cd /home/vagrant/tools
		gcc -o whereami whereami.c
		cp whereami /usr/bin/whereami
	SHELL
	#config.vm.provision "file", source: "~/.emacs", destination: ".emacs"


	# Setup multiple-slurmd which I usually don't need. Useful if I only
	# want just one VM to test something on another OS.
#	# Make my slurm directory. Use -p to ignore if it already exists.
#	config.vm.provision "shell", inline: "mkdir -p ~/slurm"
#	# Put make.py in a standard install location (already copied from tools)
#	config.vm.provision "shell", inline: "cp /home/vagrant/tools/make.py /usr/bin/make.py"
#	# exit zero so git clone doesn't fail if it already exists
#	config.vm.provision "shell", inline: "sudo -u vagrant git clone https://github.com/MarshallGarey/slurm-multicluster-dev.git /home/vagrant/slurm/22.05/install; exit 0"
#	# clone slurm because my setup script clones it with
#	# ssh rather than https, but the VM doesn't have permission to clone
#	# with ssh
#	config.vm.provision "shell", inline: "sudo -u vagrant git clone --single-branch -b slurm-22.05 https://github.com/SchedMD/slurm.git /home/vagrant/slurm/22.05/slurm; exit 0"
#	config.vm.provision "file", source: "~/slurm/vagrant/init.conf", destination: "/home/vagrant/slurm/22.05/install/init.conf"
#	config.vm.provision "shell", inline: "mysql -e \"drop user if exists vagrant@localhost; create user vagrant@localhost; grant all on *.* to 'vagrant'@'localhost';\""
#	config.vm.provision "shell", inline: "cd /home/vagrant/slurm/22.05/install; sudo -u vagrant ./setup.sh"

	# Disable NFS sync at start
	#config.vm.synced_folder '.', '/vagrant', disabled: true
	# NFS share Slurm source
	config.vm.synced_folder "/home/marshall/slurm/vagrant_centos8", "/opt/slurm", disabled: false, type: "nfs", nfs_version: "4"

	config.vm.provision "shell" do |shell|
		shell.reboot = true
		shell.inline =
			"yum -y install dnf-plugins-core epel-release
			yum config-manager --set-enabled powertools
			yum groupinstall -y 'Development Tools'
			yum -y install check-devel \
				dbus-devel \
				dejagnu \
				expect \
				gdb \
				git \
				gtk2-devel \
				glib2-devel \
				hdf5-devel \
				http-parser-devel \
				hwloc \
				hwloc-devel \
				infiniband-diags-devel \
				json-c-devel \
				libcurl-devel \
				libjwt-devel \
				libevent-devel \
				libibumad-devel \
				libssh2-devel \
				libyaml-devel \
				lua-devel \
				lz4-devel \
				man \
				man2html \
				mariadb \
				mariadb-devel \
				munge \
				munge-devel \
				ncurses-devel \
				numactl-devel \
				openssl-devel \
				pam-devel \
				perf \
				perl-ExtUtils-MakeMaker \
				perl-ExtUtils-ParseXS \
				pmix-devel \
				python3 \
				readline-devel \
				rrdtool-devel \
				valgrind \
				vim \
				which
			echo thisismysecretmungekeythatis32bytes > /etc/munge/munge.key
			chown munge:munge /etc/munge/munge.key
			chmod 0400 /etc/munge/munge.key
			systemctl disable httpd firewalld
			systemctl stop httpd firewalld
			systemctl enable munge
			systemctl restart munge
			echo -e \"192.168.255.10\tdbd\" >>/etc/hosts
			echo -e \"192.168.255.11\tctld\" >>/etc/hosts
			echo -e \"192.168.255.12\tctld-backup\" >>/etc/hosts
			groupadd --gid 500 slurm
			useradd -r --uid 500 --gid 500 --shell /sbin/nologin slurm
			mkdir /var/log/slurm /var/spool/slurm /run/slurm
			chown slurm:slurm /var/log/slurm /var/spool/slurm /run/slurm
			echo -e \"d\t/run/slurm\t0755\tslurm\tslurm\t-\t-\" > /etc/tmpfiles.d/slurm.conf

			# My username is marshall and UID is 1017 on the host
			# machine. Since I'm mounting a directory owned by my
			# user, it's easier just to add a user to the VM with
			# my same username and UID.
			useradd --uid 1017 marshall

			mount -a


			# git clone slurm; (rm -rf it first to make sure we get
			# the latest commit
#			sudo -u vagrant mkdir -p /home/vagrant/slurm/22.05
#			cd /home/vagrant/slurm/22.05
#			rm -rf slurm
#			sudo -u vagrant git clone --single-branch -b slurm-22.05 \
#				https://github.com/SchedMD/slurm.git \
#				/home/vagrant/slurm/22.05/slurm
#			sudo -u vagrant mkdir build
#			cd build
#			../slurm/configure \
#				--prefix=/opt/slurm/22.05/install \
#				--enable-developer \
#				--disable-optimizations \
#				--with-systemdsystemunitdir=/etc/systemd/system
#			make.py -a
#			"
	end

	# Copy Slurm configuration files
#	config.vm.provision "shell", inline: "mkdir -p /usr/local/etc/slurm"
#	config.vm.provision "file", source: "~/slurm/vagrant/etc", destination: "/home/vagrant/slurm/etc"
#	config.vm.provision "shell", inline: <<-SHELL
#		cp /home/vagrant/slurm/etc/* /usr/local/etc/slurm/
#		chown slurm:slurm /usr/local/etc/slurm/*
#		chown slurm:slurm /usr/local/etc/slurm
#	SHELL

	# node definitions
	config.vm.define "dbd" do |dbd|
		dbd.vm.hostname = "dbd"
		dbd.vm.network :private_network,
			:ip => '192.168.255.10',
			:libvirt__netmask => '255.255.255.0',
			:libvirt__network_name => 'clusternet',
			:libvirt__forward_mode => 'none'
		dbd.vm.provision "shell", inline: <<-SHELL
			yum -y install mariadb-server
			echo -e "[mysqld]\ninnodb_buffer_pool_size=1024M\ninnodb_log_file_size=256M\ninnodb_lock_wait_timeout=900" > /etc/my.cnf.d/slurm.cnf
			systemctl enable mariadb
			systemctl start mariadb
			mysql -e "create user if not exists slurm"
			mysql -e "create database if not exists slurm_acct_db"
			mysql -e "grant all on slurm_acct_db.* to 'slurm'"

			# Enable slurmdbd
#			systemctl enable slurmdbd
#			systemctl start slurmdbd
		SHELL
	end
	config.vm.define "ctld" do |ctld|
		ctld.vm.hostname = "ctld"
		ctld.vm.network :private_network,
			:ip => '192.168.255.11',
			:libvirt__netmask => '255.255.255.0',
			:libvirt__network_name => 'clusternet',
			:libvirt__forward_mode => 'none'

#		ctld.vm.provision "shell", inline: <<-SHELL
#			# Enable slurmctld
#			systemctl enable slurmctld
#			systemctl start slurmctld
#SHELL
	end

	# 2 nodes by default
	nodecnt = (ENV.fetch('SLURMD_NODE_CNT') { "2" }).to_i()
	(1..nodecnt).each do |i|
		config.vm.define "node#{i - 1}" do |node|
			node.vm.hostname = "node#{i - 1}"
			node.vm.network :private_network,
				:ip => "192.168.255.#{nodecnt + 99}",
				:libvirt__netmask => '255.255.255.0',
				:libvirt__network_name => 'clusternet',
				:libvirt__forward_mode => 'none'
			# cluster nodes get 2 numa nodes
#			config.vm.provider :libvirt do |node|
#				node.cpus = 4
#				node.numa_nodes = [
#					{:cpus => "0-1", :memory => "2048"},
#					{:cpus => "2-3", :memory => "2048"},
#				]
#			end

#			config.vm.provision "shell", inline: <<-SHELL
#				# Enable slurmd
#				systemctl enable slurmd
#				systemctl start slurmd
#SHELL
		end
	end
end
