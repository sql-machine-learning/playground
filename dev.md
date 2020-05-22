## Develop, Release, and Use SQLFlow-in-a-VM

### For Developers

1. Install VirtualBox and Vagrant on a computer with a relatively large memory size.
1. `git clone https://github.com/sql-machine-learning/desktop && cd desktop`
1. To build and start the VM: `vagrant up`
1. To SSH into the VM: `vagrant ssh`
1. The `vagrant up` command starts the VM and runs `provision.sh` as user `root`.  The `provision.sh` installs Docker and minikube and pulls related Docker images.  It also generates a `start.sh`.  Users should run `vagrant ssh` and execute `start.sh` inside the VM as user `vagrant`.  The `start.sh` starts minikube, deploys Argo/Tekton, and run all the services in the VM.
1. Every time we edit the `provison.sh`, we can run `vagrant provision` to rerun `provision.sh` as root.  This rerun would see the previously installed software.  So `provision.sh` contains some `if..else` structures to skip reinstalling software.
1. To suspend the VM, run `vagrant halt`.  You can run `vagrant up` later to resume it.
1. To completely destroy the VM and re-provision it, run `vagrant destroy` and `vagrant up`.

We have provided an install shell script for you to get an easy initialization.  You can run it with:
```bash
./install.sh [inchina]
```
It will guide you to setup the vagrant environment.  Especially, for developers in China, you may add the `inchina` param to download the ubuntu box for vagrant beforehand.  After the initialization, you will have a virtual machine named `playground_default...` in VirtualBox which is already provisioned.  You may follow the direction of the output to get things done.

### For Releaser

The releaser, which, in most cases, is a developer, can export a running VirtualBox VM into a VM image file with extension `.ova`.  An `ova` file is a tarball of a directory, whose content follows the OVF specification.  For the concepts, please refer to this [explanation](https://damiankarlson.com/2010/11/01/ovas-and-ovfs-what-are-they-and-whats-the-difference/).

According to this [tutorial](https://www.techrepublic.com/article/how-to-import-and-export-virtualbox-appliances-from-the-command-line/), releasers can run the following command to list running VMs.

```bash
vboxmanage list vms
```

Then, they can run the following command to export the `.ova` file.

```bash
vboxmanage export UBUNTUSERVER164 -o ubuntu_server_new.ova
```

### For End-users

To run SQLFlow on a desktop computer running Windows, Linux, or macOS, an end-user needs to download

1. the `sqlflow` command-line tool released by SQLFlow CI, and
1. the released `.ova` file.

If the end-user has VirtualBox installed -- no Vagrant required -- s/he could import the `.ova` file and start an VM.

Or, if s/he has an AWS or Google Cloud account, s/he could upload the `.ova` file to start the VM on the cloud.  AWS users can follow [these steps](https://aws.amazon.com/ec2/vm-import/).

Anyway, given a running VM, the end-user can run the following command to connect to it:

```bash
sqlflow --sqlflow_server=my-vm.aws.com:50051
```
