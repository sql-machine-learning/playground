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

CACHED_BOX="$HOME/.cache/sqlflow/ubuntu-bionic64.box"
if [[ -f $CACHED_BOX ]]; then
    vagrant box add ubuntu/bionic64 $CACHED_BOX
fi

echo "Start and provision the playgound now..."
vagrant up
