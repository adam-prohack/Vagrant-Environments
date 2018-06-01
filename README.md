# Docker Swarm and Rancher Kubernetes on Vagrant
## Requirements
* VirtualBox >= 5.2
* Vagrant >= 1.9.0
* Config Linux Transpiler (CT) >= 0.7 (https://github.com/coreos/container-linux-config-transpiler/releases)
## Configuration
* *config/config.yml* - CoreOS configuration file in **Container Linux Config** format

# CoreOS Docker Swarm
## Commands
* Run machines command: ``` vagrant up ```
* Destroy machines command: ```vagrant destroy -f```
## Environment variables
* **VAGRANT_DOCKER_COMPOSE_VERSION** - docker compose version, default: *1.19.0*
* **VAGRANT_COREOS_VERSION** - coreos version, default: *1702.1.0*
* **VAGRANT_MACHINE_PREFIX** - machine name prefix, default: *coreos-docker-swarm*
* **VAGRANT_MACHINE_IP_PREFIX** - machine ip prefix, default *172.17.8*
* **VAGRANT_NODES_COUNT** - nodes count, default: *4*
* **VAGRANT_NODE_MEMORY** - single node memory, default: *1024*
* **VAGRANT_NODE_CPUS** - single node cpus count, default: *1*
* **VAGRANT_NODE_CPU_EXECUTION_CAP** - single node cpu execution, default: *90*

# CoreOS Rancher Kubernetes
## Commands
* Run machines command: ``` vagrant up ```
* Destroy machines command: ```vagrant destroy -f```
## Environment variables
* **VAGRANT_COREOS_VERSION** - coreos version, default: *1702.1.0*
* **VAGRANT_MACHINE_PREFIX** - machine name prefix, default: *coreos-rancher-kubernetes*
* **VAGRANT_MACHINE_IP_PREFIX** - machine ip prefix, default *172.17.8*
* **VAGRANT_NODES_COUNT** - nodes count, default: *3*
* **VAGRANT_NODE_MEMORY** - single node memory, default: *1024*
* **VAGRANT_NODE_CPUS** - single node cpus count, default: *1*
* **VAGRANT_NODE_CPU_EXECUTION_CAP** - single node cpu execution, default: *90*
* **RANCHER_CLUSTER_NAME** - rancher cluster name, default *vagrant-cluster*
* **RANCHER_SERVER_LOGIN** - rancher user name, default *admin*
* **RANCHER_SERVER_PASSWORD** - rancher user password, default: *admin*
* **RANCHER_SERVER_VERSION** - rancher server container image version (min 2.0), default: *v2.0.2*