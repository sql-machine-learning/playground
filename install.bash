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

set -e

if [[ "$1" == "inchina" ]]; then
  export WE_ARE_IN_CHINA=true
fi

echo
echo "Welcome to SQLFlow playground!"
echo

if ! which vagrant >/dev/null; then
  echo "Install vagrant first, please refer to https://www.vagrantup.com/downloads.html"
  echo
  echo "If you are using macOS, the operation system may prevent you from installing the web-downloaded package, you can try use brew to install vagrant. like:"
  echo "brew cask install vagrant"
  echo
  echo "Fix this and re-run this script again please!"
  exit 0
fi

if [[ -n "$(vagrant global-status --prune | grep -o 'playground')" ]]; then
  echo "It seems you have already installed our playground, exiting..."
  exit 0
fi

echo "Installing vagrant disk size plugin..."
if [[ -z "$(vagrant plugin list | grep -o 'vagrant-disksize')" ]]; then
    vagrant plugin install vagrant-disksize
fi

if [[ "$WE_ARE_IN_CHINA" ]]; then
  if [[ -z "$(vagrant box list | grep -o ubuntu/bionic64)" ]]; then
    echo "Download ubuntu box beforehand..."
    mkdir -p downloads
    # try with https://mirrors.ustc.edu.cn/ if below not work
    wget -c -nv --show-progress -O downloads/ubuntu-bionic64.box "https://mirrors.ustc.edu.cn/ubuntu-cloud-images/bionic/current/bionic-server-cloudimg-amd64-vagrant.box"
    vagrant box add ubuntu/bionic64 downloads/ubuntu-bionic64.box
  fi
fi

echo "Start and provision the playgound now..."
vagrant up

