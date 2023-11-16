import * as pulumi from "@pulumi/pulumi";
import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";

import {
	clusterName,
	clusterNodeCount,
	clusterNodeMachineType,
} from "./config";

const engineVersion = gcp.container.getEngineVersions().then(v => v.latestMasterVersion);

export const cluster = new gcp.container.Cluster(clusterName, {
	// We can't create a cluster with no node pool defined, but we want to only use
	// separately managed node pools. So we create the smallest possible default
	// node pool and immediately delete it.
	initialNodeCount: 1,
	removeDefaultNodePool: true,
	minMasterVersion: engineVersion,
});

const nodePool = new gcp.container.NodePool("primary-node-pool", {
	cluster: cluster.name,
	initialNodeCount: clusterNodeCount,
	location: cluster.location,
	nodeConfig: {
		preemptible: true,
		machineType: clusterNodeMachineType,
		oauthScopes: [
			"https://www.googleapis.com/auth/compute",
			"https://www.googleapis.com/auth/devstorage.read_only",
			"https://www.googleapis.com/auth/logging.write",
			"https://www.googleapis.com/auth/monitoring",
		],
	},
	version: engineVersion,
	management: {
		autoRepair: true,
	},
}, {
	dependsOn: [cluster],
});

export const config = pulumi.
	all([ cluster.name, cluster.endpoint, cluster.masterAuth ]).
	apply(([ name, endpoint, auth ]) => {
    const context = `${gcp.config.project}_${gcp.config.zone}_${name}`;
    return `apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${auth.clusterCaCertificate}
    server: https://${endpoint}
  name: ${context}
contexts:
- context:
    cluster: ${context}
    user: ${context}
  name: ${context}
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${context}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: gke-gcloud-auth-plugin
      installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
        https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
      provideClusterInfo: true
`;
  });

export const provider = new k8s.Provider(`${clusterName}-provider`, {
  kubeconfig: config,
}, {
  dependsOn: [nodePool]
});
