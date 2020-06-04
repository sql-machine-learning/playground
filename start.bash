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

echo "Docker pull SQLFlow images ..."
# c.f. https://github.com/sql-machine-learning/sqlflow/blob/develop/.travis.yml
docker pull sqlflow/sqlflow:jupyter
docker pull sqlflow/sqlflow:mysql
docker pull sqlflow/sqlflow:server
docker pull sqlflow/sqlflow:step
echo "Done."

# NOTE: According to https://stackoverflow.com/a/16619261/724872,
# source is very necessary here.
source $(dirname $0)/sqlflow/scripts/travis/export_k8s_vars.sh
source $(dirname $0)/sqlflow/docker/dev/find_fastest_resources.sh

# (FIXME:lhw) If grep match nothing and return 1, do not exit
# Find a way that we do not need to use 'set -e'
set +e

# Use a faster kube image and docker registry
echo "Start minikube cluster ..."
minikube_status=$(minikube status | grep "apiserver: Running")
if [[ "$minikube_status" == "apiserver: Running" ]]; then
  echo "Already in running."
else
    ali_kube="http://kubernetes.oss-cn-hangzhou.aliyuncs.com"
    google_kube="http://k8s.gcr.io"
    fast_kube_site=$(find_fastest_url $ali_kube $google_kube)
    if [[ "$fast_kube_site" == "$ali_kube" ]]; then
        sudo minikube start --image-mirror-country cn \
          --registry-mirror=https://registry.docker-cn.com --driver=none \
          --kubernetes-version=v"$K8S_VERSION"
    else
        sudo minikube start \
          --vm-driver=none \
          --kubernetes-version=v"$K8S_VERSION"
    fi
fi

# Test if a Kubernetes resource is alive
# "$1" shoulde be namespace id e.g. argo
# "$2" should be resource id e.g. pod/argo-server
function is_resource_alive() {
    local type=$(echo "$2" | cut -d / -f1)
    local name=$(echo "$2" | cut -d / -f2)
    if kubectl get -n "$1" "$2" | grep -q -o "$name" >/dev/null; then
        # make sure relative pod is alive
        if kubectl get pod -n "$1" | grep "$name" | grep "Running" >/dev/null; then
            echo "yes"
        else
            echo "no"
        fi
    else
        echo "no"
    fi
}

echo "Start argo ..."
argo_server_alive=$(is_resource_alive "argo" "service/argo-server")
if [[ "$argo_server_alive" == "yes" ]]; then
    echo "Already in running."
else
    $(dirname $0)/sqlflow/scripts/travis/start_argo.sh
fi

echo "Strat Kubernetes Dashboard..."
dashboard_alive=$(is_resource_alive "kubernetes-dashboard" "service/kubernetes-dashboard")
if [[ "$dashboard_alive" == "yes" ]]; then
    echo "Already in running."
else
    nohup minikube dashboard &
fi

echo "Strat SQLFlow ..."
sqlflow_alive=$(is_resource_alive "default" "pod/sqlflow-server")
if [[ "$sqlflow_alive" == "yes" ]]; then
    echo "Already in running."
else
    kubectl apply -f sqlflow/doc/run/k8s/install-sqlflow.yaml
fi

# Kill port exposing if it already exist
function stop_expose() {
    ps -elf | grep "kubectl port-forward" | grep "$1" | grep "$2" | awk '{print $4}' | xargs kill  >/dev/null
}

# Kubernetes port-forwarding
# "$1" should be namespace
# "$2" should be resource, e.g. service/argo-server
# "$3" should be port mapping, e.g. 8000:80
function expose() {
    echo "Stop exposing $3..."
    stop_expose "$2" "$3"
    echo "Detecting service and exposing port ..."
    while [[ true ]]; do
        local alive=$(is_resource_alive "$1" "$2")
        if [[ "$alive" == "yes" ]]; then
            break
        fi
        sleep 1
    done
    nohup kubectl port-forward -n $1 --address='0.0.0.0' $2 $3 >>port-forward-log 2>&1 &
}

# (NOTE) after re-deploy sqlflow we have to re-expose the service ports.
expose kubernetes-dashboard service/kubernetes-dashboard 9000:80
expose argo service/argo-server 9001:2746
expose default pod/sqlflow-server 8888:8888
expose default pod/sqlflow-server 3306:3306

jupyter_addr=$(kubectl logs pod/sqlflow-server notebook | grep -o -E "http://127.0.0.1[^?]+\?token=.*" | head -1)

cat <<EOF
Congratulations, SQLFlow playground is up!

Access Jupyter Notebook at: $jupyter_addr
Access Kubernetes Dashboard at: http://localhost:9000
Access Argo Dashboard at: http://localhost:9001
Access SQLFlow with cli: refer to https://github.com/sql-machine-learning/sqlflow/blob/develop/doc/run/cli.md

Stop minikube with: minikube stop
Stop vagrant with: vagrant halt
EOF

