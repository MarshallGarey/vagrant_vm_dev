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

In my Vagrantfile, I'm forcing nfs to use version 4 because my host machine
has version 4 and the VM's need to match.

### Errors
Vagrant cannot setup virtual machines if you do not have virtualization enabled.
When you run `vagrant up`, you will see this error:
```
Error while creating domain: Error saving the server: Call to virDomainDefineXML failed: invalid argument: could not get preferred machine for /usr/bin/qemu-system-x86_64 type=kvm
```
which is totally unhelpful, but it likely means that virtualization is disabled.
Also run `virt-host-validate` to confirm:
```
marshall@curiosity:~/slurm/vagrant_vm_dev$ virt-host-validate
  QEMU: Checking for hardware virtualization                                 : PASS
  QEMU: Checking if device /dev/kvm exists                                   : PASS
  QEMU: Checking if device /dev/kvm is accessible                            : PASS
  QEMU: Checking if device /dev/vhost-net exists                             : PASS
  QEMU: Checking if device /dev/net/tun exists                               : PASS
  QEMU: Checking for cgroup 'cpu' controller support                         : PASS
  QEMU: Checking for cgroup 'cpuacct' controller support                     : PASS
  QEMU: Checking for cgroup 'cpuset' controller support                      : PASS
  QEMU: Checking for cgroup 'memory' controller support                      : PASS
  QEMU: Checking for cgroup 'devices' controller support                     : WARN (Enable 'devices' in kernel Kconfig file or mount/enable cgroup controller in your system)
  QEMU: Checking for cgroup 'blkio' controller support                       : PASS
  QEMU: Checking for device assignment IOMMU support                         : PASS
  QEMU: Checking if IOMMU is enabled by kernel                               : PASS
  QEMU: Checking for secure guest support                                    : WARN (AMD Secure Encrypted Virtualization appears to be disabled in firmware.)
   LXC: Checking for Linux >= 2.6.26                                         : PASS
   LXC: Checking for namespace ipc                                           : PASS
   LXC: Checking for namespace mnt                                           : PASS
   LXC: Checking for namespace pid                                           : PASS
   LXC: Checking for namespace uts                                           : PASS
   LXC: Checking for namespace net                                           : PASS
   LXC: Checking for namespace user                                          : PASS
   LXC: Checking for cgroup 'cpu' controller support                         : PASS
   LXC: Checking for cgroup 'cpuacct' controller support                     : PASS
   LXC: Checking for cgroup 'cpuset' controller support                      : PASS
   LXC: Checking for cgroup 'memory' controller support                      : PASS
   LXC: Checking for cgroup 'devices' controller support                     : FAIL (Enable 'devices' in kernel Kconfig file or mount/enable cgroup controller in your system)
   LXC: Checking for cgroup 'freezer' controller support                     : FAIL (Enable 'freezer' in kernel Kconfig file or mount/enable cgroup controller in your system)
   LXC: Checking for cgroup 'blkio' controller support                       : PASS
```
If you are running cgroup v2, you will also see `FAIL` when checking for
cgroup devices and freezer support. It's nothing to worry about.
See the following link for an explanation:
https://gitlab.com/libvirt/libvirt/-/issues/94
