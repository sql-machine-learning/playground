#!/bin/bash

echo "Stoping the vm ..."
vagrant halt
echo "Done."

echo "Finding playground vm ..."
vm=$(VBoxManage list vms | grep "playground_default" | head -1)
if [[ ! "$vm" =~ playground_default* ]]; then
    echo "No palyground virtual machine found."
    exit 1
fi
vm=$(echo $vm | awk -F"\"" '{print $2}')
echo "Found $vm ."

echo "Remove shared folder ..."
VBoxManage sharedfolder remove "$vm" --name home_vagrant_desktop
VBoxManage sharedfolder remove "$vm" --name vagrant
echo "Done."

echo "Exporting vm ..."
VBoxManage export "$vm" -o SQLFlowPlayground.ova
echo "Done."
