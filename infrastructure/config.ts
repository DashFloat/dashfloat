import { Config } from "@pulumi/pulumi";

const config = new Config();

export const clusterName = config.require("clusterName");
export const clusterNodeCount = config.getNumber("clusterNodeCount") || 1;
export const clusterNodeMachineType = config.get("clusterNodeMachineType") || "n1-standard-1";
export const clusterUsername = config.requireSecret("clusterUsername")
export const clusterPassword = config.requireSecret("clusterPassword");
