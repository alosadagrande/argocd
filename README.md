# Applying cluster configuration

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
