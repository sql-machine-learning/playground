# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.provision "shell", path: "provision.sh"

  # Don't forward 22.  Even if we do so, the exposed port only binds
  # to 127.0.0.1, but not 0.0.0.0.  Other ports binds to all IPs.
  config.vm.network "forwarded_port", guest: 3306, host: 3306
  config.vm.network "forwarded_port", guest: 50051, host: 50051
  config.vm.network "forwarded_port", guest: 8888, host: 8888

  config.vm.provider "virtualbox" do |v|
    v.memory = 16384
    v.cpus = 8
  end

  # Bind the host directory ./ into the VM.
  config.vm.synced_folder "./", "/home/vagrant/desktop"
end
