# Provision SQLFlow Desktop for Linux

I use Ubuntu 18.04 as the base Vagrant image.  The following commands
download the VM image, starts a VM, and SSH into this VM.

```bash
vagrant init ubuntu/bionic64
vagrant up
vagrant ssh
```

In the VM, I need to install Docker.

```bash
sudo apt update
sudo apt install -y docker.io
```
