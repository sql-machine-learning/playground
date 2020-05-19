#!/bin/bash

set -e  # Exit script if any error


echo "Installing Docker ..."
# c.f. https://dockr.ly/3cExcay
if which docker > /dev/null; then
    echo "Docker had been installed. Skip."
else
    curl -fsSL https://get.docker.com | sh -
    usermod -aG docker vagrant
fi
echo "Done."


echo "Docker pull SQLFlow images ..."
# c.f. https://github.com/sql-machine-learning/sqlflow/blob/develop/.travis.yml
docker pull --quiet sqlflow/sqlflow:latest
echo "Done."


echo "Export Kubernetes environment variables ..."
$(dirname $0)/sqlflow/scripts/travis/export_k8s_vars.sh

echo "Installing kubectl ..."
if which kubectl > /dev/null; then
    echo "kubectl installed. Skip."
else
    $(dirname $0)/sqlflow/scripts/travis/install_kubectl.sh
fi
echo "Done."


echo "Installing minikube ..."
if which minikube > /dev/null; then
    echo "minikube installed. Skip."
else
    $(dirname $0)/sqlflow/scripts/travis/install_minikube.sh
fi
echo "Done."


echo "Configure minikube ..."
mkdir -p /home/vagrant/.kube /home/vagrant/.minikube
touch /home/vagrant/.kube/config
chown -R vagrant /home/vagrant/.bashrc
echo "Done."
