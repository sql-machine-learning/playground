## Develop, Release, and Use SQLFlow-in-a-VM

### For Developers

1. Install VirtualBox and Vagrant on a computer with a relatively large memory size.
1. Clone and update `SQLFlow playground` project.
    ```bash
    git clone https://github.com/sql-machine-learning/playground.git
    cd playground
    git submodule update --init
    ```
1. Run the `play.sh` under playgound's root directory.  This script will guide you to install SQLFlow on a virtualbox VM.  If you have a slow Internet connection to Vagrant Cloud, you might want to download the Ubuntu VirtualBox image manually from some mirror sites into `~/.cache/sqlflow/` before running the above script.  We use `get -c` here for continuing get the file from last breakpoint, so if this command fail, just re-run it.
    ```bash
    mkdir -p $HOME/.cache/sqlflow
    wget -c -O $HOME/.cache/sqlflow/ubuntu-bionic64.box \
      "https://mirrors.ustc.edu.cn/ubuntu-cloud-images/bionic/current/bionic-server-cloudimg-amd64-vagrant.box"
    ```
    The `start.sh` add some extensions for Vagrant, like `vagrant-disksize` which enlarge the disk size of the VM.  The script will then call `vagrant up` command to bootup the VM.  After the VM is up, the `provision.sh` will be automatically executed which will install the dependencies for SQLFlow.  Provision is a one-shot work, after it is done, we will have an environment with SQLFlow, docker and minikube installed.

1. Log on the VM and start SQLFlow playground.  Run the `start.bash` script, it will pull some docker images and start the playground minikube cluster.  As the images pulling may be slow, the script might fail sometimes.  Feel free to re-run the script until gou get some output like `Access Jupyter Notebook at ...`.
    ```bash
    vagrant ssh
    sudo su
    cd desktop
    ./start.bash
    ```
1. After the minikube is started up. You can and access the `Jupyter Notebook` from your desktop. Or you can use SQLFlow command-line tool `sqlflow` to access the `SQLFlow server`.  Just follow the output of the `start.bash`, it will give you some hint.
1. After playing a while, you may want to stop SQLFlow playground, just log on the VM again and stop the minikube cluster.
    ```bash
    vagrant ssh # optional if you already logged on
    minikube stop
    ```
1. Finally if you want to stop the VM, you can run the `vagrant halt` command.  To complete destroy the VM, run the `vagrant destroy` command.

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
