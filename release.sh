#!/bin/bash

# Copyright 2020 The SQLFlow Authors. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


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

echo "Rebind serial port file and disable it because it does not work on Windows"
VBoxManage modifyvm "$vm" --uartmode1 file /tmp/playground.log
VBoxManage modifyvm "$vm" --uart1 off
echo "Done."

echo "Exporting vm ..."
VBoxManage export "$vm" -o SQLFlowPlayground.ova
echo "Done."
