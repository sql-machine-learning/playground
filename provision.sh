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


echo "Set Kubernetes environment variables ..."
cat >> /home/vagrant/.bashrc <<EOF
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=/home/vagrant
export CHANGE_MINIKUBE_NONE_USER=true
export KUBECONFIG=/home/vagrant/.kube/config
export K8S_VERSION=v1.18.2
export MINIKUBE_VERSION=1.1.1
EOF
export K8S_VERSION=v1.18.2
echo "Done."


echo "Installing kubectl ..."
if which kubectl > /dev/null; then
    echo "kubectl installed. Skip."
else
    SITE="https://storage.googleapis.com/kubernetes-release/release"
    curl -sLo /usr/local/bin/kubectl \
         "$SITE/$K8S_VERSION/bin/linux/amd64/kubectl"
    chmod +x /usr/local/bin/kubectl
fi
echo "Done."


echo "Installing minikube ..."
# c.f. https://kubernetes.io/docs/tasks/tools/install-minikube/
if which minikube > /dev/null; then
    echo "minikube installed. Skip."
else
    SITE="https://storage.googleapis.com/minikube/releases"
    curl -sLo /usr/local/bin/minikube "$SITE/latest/minikube-linux-amd64"
    chmod +x /usr/local/bin/minikube
fi
echo "Done."


echo "Configure minikube ..."
mkdir -p /home/vagrant/.kube /home/vagrant/.minikube
touch /home/vagrant/.kube/config
chown -R vagrant /home/vagrant/.bashrc
echo "Done."


echo "Start minikube cluster ..."
if which conntrack > /dev/null; then
    echo "Skip installing contrack because it has been installed."
else
    # Kubernetes 1.18.2 requires conntrack.
    sudo apt-get -qq install -y conntrack
fi
echo "Done."


echo "Write /home/vagrant/start_minikube.sh ..."
cat > /home/vagrant/start_minikube.sh <<EOF
echo "Start minikube ..."
sudo minikube start \
     --vm-driver=none \
     --kubernetes-version=$K8S_VERSION
sudo chown -R vagrant: $HOME/.minikube/
kubectl cluster-info

echo "Install Argo on minikube cluster ..."
kubectl create namespace argo
kubectl apply -n argo -f \
  https://raw.githubusercontent.com/argoproj/argo/v2.7.7/manifests/install.yaml
kubectl create rolebinding default-admin \
  --clusterrole=admin \
  --serviceaccount=default:default
echo "Done."
EOF
chmod +x /home/vagrant/start_minikube.sh
chown -R vagrant /home/vagrant/start_minikube.sh
