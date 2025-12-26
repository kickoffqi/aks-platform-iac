<!--
  Repo: aks-platform-iac
  Purpose: reproducible AKS platform provisioning + k8s manifests
-->

# AKS Platform IaC

This repository contains reusable Terraform modules, per-environment stacks, and Kustomize overlays for standing up an Azure Kubernetes Service (AKS) platform with its core dependencies (networking, Azure Container Registry, RBAC wiring) and shipping baseline Kubernetes manifests.

## Repository Layout

| Path | Description |
| --- | --- |
| `infra/terraform/modules/network` | Virtual network, subnet, and resource group definitions shared by all environments. |
| `infra/terraform/modules/acr` | Azure Container Registry with deterministic naming + tags. |
| `infra/terraform/modules/aks` | AKS cluster, system node pool, two user pools, autoscaler toggles, and kubelet identity outputs. |
| `infra/terraform/envs/dev` | Root module that wires modules together and assigns the `AcrPull` role. Duplicate this folder for new environments. |
| `infra/k8s/base` | Base Kubernetes manifests expressed as Kustomize resources. |
| `infra/k8s/overlays/dev` | Dev-specific patches layered over the base manifests. |
| `scripts/bootstrap.sh` | Helper script stub for future automation (credentials, tooling, etc.). |

## Prerequisites

- Terraform >= 1.5
- Azure CLI authenticated against the target subscription
- Remote state storage prepared (Azure Storage account + container)
- Sufficient RBAC permissions to create resource groups, VNETs, AKS, and ACR resources

## Getting Started (Dev Environment)

1. **Navigate** to the dev stack:

   ```bash
   cd infra/terraform/envs/dev
   ```

2. **Initialize** Terraform with your backend settings:

   ```bash
   terraform init \
     -backend-config="resource_group_name=<rg>" \
     -backend-config="storage_account_name=<storage>" \
     -backend-config="container_name=<container>" \
     -backend-config="key=dev.terraform.tfstate"
   ```

3. **Review variables** in `terraform.tfvars` (name prefix, location, VM sizes, autoscaler bounds) and adjust as needed.

4. **Plan and apply**:

   ```bash
   terraform plan -out tfplan
   terraform apply tfplan
   ```

5. **Retrieve cluster credentials** once Terraform completes:

   ```bash
   az aks get-credentials \
     --resource-group <rg> \
     --name <cluster-name>
   ```

6. **Deploy Kubernetes addons** using Kustomize (example for dev):

   ```bash
   cd ../../k8s/overlays/dev
   kustomize build . | kubectl apply -f -
   ```

## Configuration Highlights

- **Networking**: `/16` VNET with `/24` subnet reserved for AKS; edit CIDRs in `modules/network/variables.tf` if needed.
- **Node Pools**: `system` pool restricts workloads to critical addons. Two user pools (`user1`, `user2`) can scale independently with autoscaler toggles exposed via variables.
- **ACR Integration**: `azurerm_role_assignment` ensures the AKS kubelet identity has `AcrPull` permissions against the registry provisioned in the same resource group.
- **Tagging**: All modules accept `var.tags` to enforce consistent metadata (cost center, environment, owner, etc.).

## Working With Multiple Environments

1. Copy `infra/terraform/envs/dev` to a new folder (e.g., `stage`).
2. Update `terraform.tfvars` with the new environment name, backend key, and sizing.
3. Optionally create a matching Kustomize overlay under `infra/k8s/overlays/<env>` to hold environment-specific manifests.

## Troubleshooting Tips

- Ensure the subnet has enough IPs for planned scale; adjust `address_prefixes` if pods fail to schedule.
- When changing AKS VM sizes, keep the `temporary_name_for_rotation` field populated to avoid rotation errors.
- Use `terraform state list` to confirm resources before destructive operations.
- For pull errors from ACR, verify that the role assignment in the root module completed and that the kubelet identity matches the AKS cluster’s managed identity.

## Next Steps

- Add monitoring/logging modules (Azure Monitor, Log Analytics) under `infra/terraform/modules`.
- Grow the Kustomize base with core platform workloads (ingress, cert-manager, policy controllers).
- Integrate CI/CD to lint Terraform, enforce `terraform fmt`, and run `kustomize build` smoke checks.
