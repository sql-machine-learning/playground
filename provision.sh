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

echo "Installing minikube ..."
# c.f. https://kubernetes.io/docs/tasks/tools/install-minikube/
if which minikube > /dev/null; then
    echo "minikube installed. Skip."
else
    SITE="https://storage.googleapis.com/minikube/releases"
    curl -sLo /usr/local/bin/minikube "$SITE/latest/minikube-linux-amd64"
    chmod +x /usr/local/bin/minikube
fi

echo "Installing kubectl ..."
if which kubectl > /dev/null; then
    echo "kubectl installed. Skip."
else
    SITE="https://storage.googleapis.com/kubernetes-release/release"
    curl -sLo /usr/local/bin/kubectl \
         "$SITE"/$(curl -s "$SITE/stable.txt")"/bin/linux/amd64/kubectl"
    chmod +x /usr/local/bin/kubectl
fi
