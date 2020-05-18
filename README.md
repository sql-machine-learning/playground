# Provision SQLFlow Desktop for Linux

This is an experimental work to check deploying the whole SQLFlow
service mesh on a Ubuntu 18.04 VM.

The general architecture of SQLFlow is as the following:

![](figures/arch.svg)

In this deployment, we have Jupyter Notebook server, SQLFlow server,
and MySQL running in a container executing the
`sqlflow/sqlflow:latest` image.  Argo runs on a minikube cluster
running on the VM.  The deployment is shown in the folllowing figure:

![](figures/arch_vm.svg)
