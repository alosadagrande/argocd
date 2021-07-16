# Configuring OpenShift with ArgoCD for telco configuration

This repo is intended to be used to install and configure the regular operators used in telco space: SR-IOV, Performance Addon Operator, Virtualization or NMstate. It also includes non telco specific configuration such as monitoring, alertmanager, authentication or adding extra SSH keys to the cluster nodes.

The repo is divided into several branches:

* Main branch. It includes a script to install upstream ArgoCD in OpenShift, the application to be created in ArgoCD and all the configuration required to install the telco operators for different OCP versions: 4.6, 4.7 and 4.8
* Cluster branches. These branches basically includes all the configuration files for the operators installed from the main branch. These configurations differs a little bit from the several OpenShift versions, so each version beginning in 4.6 has its configuration folder.


# ArgoCD installation

In OpenShift you can install from OperatorHub the GitOps operator which installs ArgoCD. Currently it is installing version 1.x. In my case I wanted to use the latest bits so that's why I am installing the upstream version of ArgoCD. 

The installation of the ArgoCD is triggered by running the `argo-upstream-install.sh`. Take a look at the simple script and change it accordingly to your needs.

```
$ ./argo-upstream-install.sh
```

# Installing the CNF Operators

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
