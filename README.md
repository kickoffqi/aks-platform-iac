# aks-platform-iac

Infrastructure-as-Code repo for AKS platform.

## Structure

- `infra/terraform/modules` - reusable Terraform modules
- `infra/terraform/envs/dev` - dev environment root module
- `infra/k8s/base` - base Kubernetes manifests (Kustomize)
- `infra/k8s/overlays/dev` - dev overlay (Kustomize)

## Terraform quick start (dev)

From `infra/terraform/envs/dev`:

1. Initialize backend (recommended via backend-config flags):

   ```bash
   terraform init \
     -backend-config="resource_group_name=<rg>" \
     -backend-config="storage_account_name=<sa>" \
     -backend-config="container_name=<container>" \
     -backend-config="key=dev.terraform.tfstate"
   ```

2. Plan/apply:

   ```bash
   terraform plan
   terraform apply
   ```
