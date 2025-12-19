#!/usr/bin/env bash
set -euo pipefail

ENV_DIR="infra/terraform/envs/dev"

# 你可以通过环境变量覆盖
SUB_ID="${AZURE_SUBSCRIPTION_ID:-}"
LOCATION="${LOCATION:-australiaeast}"

RG_NAME="${RG_NAME:-rg-aks-platform-dev}"
AKS_NAME="${AKS_NAME:-aks-platform-dev}"

# tfstate 资源（必须唯一）
TFSTATE_RG="${TFSTATE_RG:-rg-tfstate-aks-platform-dev}"
TFSTATE_SA="${TFSTATE_SA:-sttfstate1765767447}"   # 你可以用你之前那套时间戳风格
TFSTATE_CONTAINER="${TFSTATE_CONTAINER:-tfstate}"
TFSTATE_KEY="${TFSTATE_KEY:-aks-platform-dev.tfstate}"

if [[ -z "$SUB_ID" ]]; then
  echo "[ERROR] AZURE_SUBSCRIPTION_ID is required"
  exit 1
fi

echo "[INFO] Using subscription: $SUB_ID"
az account set --subscription "$SUB_ID"

echo "[INFO] Ensure tfstate RG..."
az group show -n "$TFSTATE_RG" >/dev/null 2>&1 || az group create -n "$TFSTATE_RG" -l "$LOCATION" 1>/dev/null

echo "[INFO] Ensure tfstate Storage Account..."

# 先在 subscription 内搜索同名 storage account
EXISTING_SA_ID="$(az storage account list \
  --query "[?name=='$TFSTATE_SA'].id | [0]" -o tsv)"

if [[ -n "$EXISTING_SA_ID" ]]; then
  EXISTING_SA_RG="$(az storage account show --ids "$EXISTING_SA_ID" --query resourceGroup -o tsv)"
  echo "[INFO] Storage account $TFSTATE_SA already exists in RG: $EXISTING_SA_RG"
  TFSTATE_RG="$EXISTING_SA_RG"
else
  echo "[INFO] Creating storage account $TFSTATE_SA in RG: $TFSTATE_RG"
  az storage account create -g "$TFSTATE_RG" -n "$TFSTATE_SA" -l "$LOCATION" --sku Standard_LRS 1>/dev/null
fi

echo "[INFO] Ensure tfstate container..."
SA_KEY="$(az storage account keys list -g "$TFSTATE_RG" -n "$TFSTATE_SA" --query '[0].value' -o tsv)"
az storage container create --name "$TFSTATE_CONTAINER" --account-name "$TFSTATE_SA" --account-key "$SA_KEY" 1>/dev/null

cd "$ENV_DIR"

echo "[INFO] terraform init (remote state)..."
terraform init \
  -backend-config="resource_group_name=$TFSTATE_RG" \
  -backend-config="storage_account_name=$TFSTATE_SA" \
  -backend-config="container_name=$TFSTATE_CONTAINER" \
  -backend-config="key=$TFSTATE_KEY"

# ---- Import if exists (RG/AKS/nodepools) ----
# RG
if az group show -n "$RG_NAME" >/dev/null 2>&1; then
  echo "[INFO] Import existing RG..."
  terraform import -no-color 'module.network.azurerm_resource_group.rg' \
    "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME" || true
fi

# AKS
if az aks show -g "$RG_NAME" -n "$AKS_NAME" >/dev/null 2>&1; then
  echo "[INFO] Import existing AKS..."
  terraform import -no-color 'module.aks.azurerm_kubernetes_cluster.aks' \
    "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME/providers/Microsoft.ContainerService/managedClusters/$AKS_NAME" || true

  for NP in user1 user2; do
    if az aks nodepool show -g "$RG_NAME" --cluster-name "$AKS_NAME" -n "$NP" >/dev/null 2>&1; then
      echo "[INFO] Import existing nodepool $NP..."
      terraform import -no-color "module.aks.azurerm_kubernetes_cluster_node_pool.${NP}" \
        "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME/providers/Microsoft.ContainerService/managedClusters/$AKS_NAME/agentPools/$NP" || true
    fi
  done
fi

echo "[INFO] terraform plan..."
terraform plan

echo "[INFO] terraform apply..."
terraform apply -auto-approve