# Configuring OpenShift with ArgoCD for telco configuration

This repo is intended to be used to install and configure the regular operators used in telco space: SR-IOV, Performance Addon Operator, Virtualization or NMstate. It also includes non telco specific configuration such as monitoring, alertmanager, authentication or adding extra SSH keys to the cluster nodes.

The repo is divided into several branches:

* Main branch. It includes a script to install upstream ArgoCD in OpenShift, the application to be created in ArgoCD and all the configuration required to install the telco operators for different OCP versions: 4.6, 4.7 and 4.8
* Cluster branches. These branches basically includes all the configuration files for the operators installed from the main branch. These configurations differs a little bit from the several OpenShift versions, so each version beginning in 4.6 has its configuration folder.


## ArgoCD installation

In OpenShift you can install from OperatorHub the GitOps operator which installs ArgoCD. Currently it is installing version 1.x. In my case I wanted to use the latest bits so that's why I am installing the upstream version of ArgoCD. 

The installation of the ArgoCD is triggered by running the `argo-upstream-install.sh`. Take a look at the simple script and change it accordingly to your needs.

```
$ ./argo-upstream-install.sh
```

## Installing the CNF Operators

In order to install the CNF operators you need to apply the cnf-operators ArgoCD Application that matches the version of your OCP cluster:

```sh
$ oc create -f cnf-operators-4.8.yaml
```

Then you can check the status of the deployment either on the ArgoCD user interface or by checking the status of the application:

```sh
$ oc get -oyaml applications cnf-operators
```
Notice here the the folder structure of the repository. See for instance that NMState Operator is not available in OCP 4.6, that's why we are installing CNV. Once it is available in the following releases, we just replace it.

:warning: The point of having folders for each version is because yaml definitions are different. A better approach it could've been to use kustomize extensively by having a base folder and applying just the changes in each folder instead of replicate the full structure.

```sh
├── argo-upstream-install.sh
├── cnf-operators-4.6.yaml
├── cnf-operators-4.7.yaml
├── cnf-operators-4.8.yaml
├── deploy
│   ├── 4.6
│   │   └── enabled
│   │       ├── cnv
│   │       │   ├── 01-cnv-namespace.yaml
│   │       │   ├── 02-cnv-operatorgroup.yaml
│   │       │   ├── 03-cnv-subscription.yaml
│   │       │   └── 04-cnv-operator.yaml
│   │       ├── kustomization.yaml
│   │       ├── performance
│   │       │   ├── operator_catalogsource.yaml
│   │       │   ├── operator-namespace.yaml
│   │       │   ├── operator_operatorgroup.yaml
│   │       │   └── operator_subscription.yaml
│   │       └── sriov
│   │           ├── 01-sriov-namespace.yaml
│   │           ├── 02-sriov-operatorgroup.yaml
│   │           └── 03-sriov-subscription.yaml
│   ├── 4.7
│   │   └── enabled
│   │       ├── cnv
│   │       │   ├── 01-cnv-namespace.yaml
│   │       │   ├── 02-cnv-operatorgroup.yaml
│   │       │   ├── 03-cnv-subscription.yaml
│   │       │   └── 04-cnv-operator.yaml
│   │       ├── kustomization.yaml
│   │       ├── nmstate
│   │       │   ├── 01-nmstate-namespace.yaml
│   │       │   ├── 02-nmstate-operatorgroup.yaml
│   │       │   └── 03-nmstate-subscription.yaml
│   │       ├── performance
│   │       │   ├── 01-pao-namespace.yaml
│   │       │   ├── 02-pao-operatorgroup.yaml
│   │       │   └── 03-pao-subscription.yaml
│   │       └── sriov
│   │           ├── 01-sriov-namespace.yaml
│   │           ├── 02-sriov-operatorgroup.yaml
│   │           └── 03-sriov-subscription.yaml
│   ├── 4.8
│   │   └── enabled
│   │       ├── kustomization.yaml
│   │       ├── nmstate
│   │       │   ├── 01-nmstate-namespace.yaml
│   │       │   ├── 02-nmstate-operatorgroup.yaml
│   │       │   ├── 03-nmstate-subscription.yaml
│   │       │   └── 04-nmstate-instance.yaml
│   │       ├── performance
│   │       │   ├── 01-pao-namespace.yaml
│   │       │   ├── 021-pao-catalogsource.yaml
│   │       │   ├── 02-pao-operatorgroup.yaml
│   │       │   └── 03-pao-subscription.yaml
│   │       └── sriov
│   │           ├── 01-sriov-namespace.yaml
│   │           ├── 02-sriov-operatorgroup.yaml
│   │           └── 03-sriov-subscription.yaml
```

## Applying cluster configuration

Now that we have the required operators installed we need to properly configure. In order to do that we need to adapt to the hardware resources that each cluster has. That's why we have create a branch for each cluster, so for instance the branch cnf-cluster1 is focused on configuring our OCP cluster1 cluster.

So, first we need to adapt the configuration to the cluster resources and requirements. Here you can see the folder structure and the different configuration we are going to apply. Notice we apply cluster configurations as well such as oauth or alerting.

```sh

├── argo-upstream-install.sh
├── cnf-cluster1-4.6.yaml
├── cnf-cluster1-4.7.yaml
├── cnf-cluster1-4.8.yaml
├── deploy
│   ├── 4.6
│   │   └── enabled
│   │       ├── auth
│   │       │   ├── htpass-secret.yaml
│   │       │   └── oauth.yaml
│   │       ├── cnv
│   │       │   └── nncp-standard-bond0.yaml
│   │       ├── kustomization.yaml
│   │       ├── label-ht.yaml
│   │       ├── mcp-worker-ht.yaml
│   │       ├── mcp-worker-standard.yaml
│   │       ├── monitoring
│   │       │   ├── alertmanager-main.yaml
│   │       │   └── cluster-monitoring-config.yaml
│   │       ├── ntp
│   │       │   ├── 99-master-chrony-configuration.yaml
│   │       │   └── 99-worker-chrony-configuration.yaml
│   │       ├── performance
│   │       │   └── performance_profile_ht.yaml
│   │       └── sriov
│   │           ├── sriov-network-node-policy-mlx-netdevice.yaml
│   │           ├── sriov-network-node-policy-mlx-vfio.yaml
│   │           └── sriovoperatorconfig.yaml
│   ├── 4.7
│   │   └── enabled
│   │       ├── auth
│   │       │   ├── htpass-secret.yaml
│   │       │   └── oauth.yaml
│   │       ├── kustomization.yaml
│   │       ├── label-ht.yaml
│   │       ├── mcp-worker-ht.yaml
│   │       ├── mcp-worker-standard.yaml
│   │       ├── monitoring
│   │       │   ├── alertmanager-main.yaml
│   │       │   └── cluster-monitoring-config.yaml
│   │       ├── nmstate
│   │       │   ├── nmstate-instance.yaml
│   │       │   └── nncp-standard-bond0.yaml
│   │       ├── ntp
│   │       │   ├── 99-master-chrony-configuration.yaml
│   │       │   └── 99-worker-chrony-configuration.yaml
│   │       ├── performance
│   │       │   └── performance_profile_ht.yaml
│   │       └── sriov
│   │           ├── sriov-network-node-policy-mlx-netdevice.yaml
│   │           ├── sriov-network-node-policy-mlx-vfio.yaml
│   │           └── sriovoperatorconfig.yaml
│   └── 4.8
│       └── enabled
│           ├── auth
│           │   ├── htpass-secret.yaml
│           │   └── oauth.yaml
│           ├── kustomization.yaml
│           ├── label-ht.yaml
│           ├── machineconfigs
│           │   ├── 99-master-ssh.yaml
│           │   └── 99-worker-ssh.yaml
│           ├── mcp-worker-ht.yaml
│           ├── mcp-worker-standard.yaml
│           ├── monitoring
│           │   ├── alertmanager-main.yaml
│           │   └── cluster-monitoring-config.yaml
│           ├── nmstate
│           │   └── nncp-standard-bond0.yaml
│           ├── ntp
│           │   ├── 99-master-chrony-configuration.yaml
│           │   └── 99-worker-chrony-configuration.yaml
│           ├── performance
│           │   └── performance_profile_ht.yaml
│           ├── ptp
│           │   ├── 01_namespace.yaml
│           │   ├── 02_operator_group.yaml
│           │   ├── 03_subscription.yaml
│           │   └── kustomization.yaml
│           ├── sctp
│           │   ├── is_ready.sh
│           │   ├── kustomization.yaml
│           │   └── sctp_module_mc.yaml
│           └── sriov
│               ├── sriov-network-node-policy-mlx-netdevice.yaml
│               ├── sriov-network-node-policy-mlx-vfio.yaml
│               └── sriovoperatorconfig.yaml

```

In order to apply the configuration you need to apply the cnf-cluster1 ArgoCD Application that matches the version of your OCP cluster:

```sh
$ oc create -f cnf-cluster1-4.8.yaml
```

Then you can check the status of the deployment either on the ArgoCD user interface or by checking the status of the application:

```sh
$ oc get -oyaml applications cnf-cluster1
```

:warning: The point of having folders for each version is because yaml definitions are different or they have different API versions. For instance, the performanceprofile changes quite a few settings from 4.6 to 4.7 channels. A better approach could've been to use kustomize extensively by having a base folder and applying just the changes in each folder instead of replicate the full structure.

## Conclusion

At this point a basic GitOps configuration is set up. Now you are able to commit changes to either the configuration application or even include new operators to be installed in the cnf-operators application. Changes commited in the proper repo will be replicated into the cluster where ArgoCD is installed and configured to continuously seek changes in the git repo.
