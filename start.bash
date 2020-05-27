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

echo "Docker pull SQLFlow images ..."
# c.f. https://github.com/sql-machine-learning/sqlflow/blob/develop/.travis.yml
docker pull sqlflow/sqlflow:latest
echo "Done."

# NOTE: According to https://stackoverflow.com/a/16619261/724872,
# source is very necessary here.
source $(dirname $0)/sqlflow/scripts/travis/export_k8s_vars.sh

$(dirname $0)/sqlflow/scripts/travis/start_minikube.sh
sudo chown -R vagrant: $HOME/.minikube/

$(dirname $0)/sqlflow/scripts/travis/start_argo.sh
