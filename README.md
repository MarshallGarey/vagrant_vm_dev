# Very helpful title
This is where I'm keeping track of my Vagrant configuration.
I'm using Vagrant to setup virtual machines to run Slurm.

## Helpful documentation

### Installing Vagrant

I got the initial setup for Vagrant here:
https://github.com/mcmult/slurm-vagrant

### Setting up synced folders:

https://www.vagrantup.com/docs/synced-folders

I use an nfs mount.

I needed to allow Vagrant to modify my mounts, so I added a file to
`/etc/sudoers.d/` and put the following in it:
```
# Allow vagrant to mess with nfs
Cmnd_Alias VAGRANT_EXPORTS_CHOWN = /bin/chown 0\:0 /tmp/*
Cmnd_Alias VAGRANT_EXPORTS_MV = /bin/mv -f /tmp/* /etc/exports
Cmnd_Alias VAGRANT_NFSD_CHECK = /etc/init.d/nfs-kernel-server status
Cmnd_Alias VAGRANT_NFSD_START = /etc/init.d/nfs-kernel-server start
Cmnd_Alias VAGRANT_NFSD_APPLY = /usr/sbin/exportfs -ar
%sudo ALL=(root) NOPASSWD: VAGRANT_EXPORTS_CHOWN, VAGRANT_EXPORTS_MV, VAGRANT_NFSD_CHECK, VAGRANT_NFSD_START, VAGRANT_NFSD_APPLY
```
