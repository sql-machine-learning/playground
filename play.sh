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

cat <<EOF
 ___  ___  _    ___ _
/ __|/ _ \| |  | __| |_____ __ __
\__ \ (_) | |__| _|| / _ \ V  V /
|___/\__\_\____|_| |_\___/\_/\_/

EOF

if ! which vagrant >/dev/null; then
    cat <<EOF
We need Vagrant to run the playground.

Linux users can refer to https://www.vagrantup.com/downloads.html for the
installation guide.

macOS users can install Vagrant using Homebrew:
  brew cask install vagrant
EOF
    exit 1
fi

if [[ -n "$(vagrant global-status --prune | grep -o 'playground')" ]]; then
    echo "The playground VM is running."
    exit 0
fi

if [[ -z "$(vagrant plugin list | grep -o 'vagrant-disksize')" ]]; then
    echo "Install Vagrant disk size plugin ..."
    vagrant plugin install vagrant-disksize
fi

CACHED_BOX="$HOME/.cache/sqlflow/ubuntu-bionic64.box"
if [[ -f $CACHED_BOX ]]; then
    echo "Found and use cached box $CACHED_BOX"
    vagrant box add ubuntu/bionic64 $CACHED_BOX
fi

echo "Start and provision the playgound VM ..."
vagrant up
