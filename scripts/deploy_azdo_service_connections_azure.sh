#######################################################
# Deploys Azure DevOps Azure Service Connections
#
# Prerequisites:
# - User is logged in to the azure cli
# - Correct Azure subscription is selected
# - Correct Azure DevOps Project selected
#######################################################

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace # For debugging

###################
# REQUIRED ENV VARIABLES:
#
# PROJECT
# ENV_NAME
# RESOURCE_GROUP_NAME

###############
# Setup Azure service connection
az_service_connection_name="${PROJECT}-serviceconnection-$ENV_NAME"

az_sub=$(az account show --output json)
az_sub_id=$(echo "$az_sub" | jq -r '.id')
az_sub_name=$(echo "$az_sub" | jq -r '.name')

# Create Service Account
az_sp_name=${PROJECT}-${ENV_NAME}-sp
echo "Creating service principal: $az_sp_name for azure service connection"
az_sp=$(az ad sp create-for-rbac \
    --role contributor \
    --scopes "/subscriptions/${az_sub_id}/resourceGroups/${RESOURCE_GROUP_NAME}" \
    --name "$az_sp_name" \
    --output json)
service_principal_id=$(echo "$az_sp" | jq -r '.appId')
az_sp_tenant_id=$(echo "$az_sp" | jq -r '.tenant')

# Create Azure Service connection in Azure DevOps
azure_devops_ext_azure_rm_service_principal_key=$(echo "$az_sp" | jq -r '.password')
export AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$azure_devops_ext_azure_rm_service_principal_key

if sc_id=$(az devops service-endpoint list -o tsv | grep "$az_service_connection_name" | awk '{print $3}'); then
    echo "Service connection: $az_service_connection_name already exists. Deleting..."
    az devops service-endpoint delete --id "$sc_id" -y
fi
echo "Creating Azure service connection Azure DevOps"
sc_id=$(az devops service-endpoint azurerm create \
    --name "$az_service_connection_name" \
    --azure-rm-service-principal-id "$service_principal_id" \
    --azure-rm-subscription-id "$az_sub_id" \
    --azure-rm-subscription-name "$az_sub_name" \
    --azure-rm-tenant-id "$az_sp_tenant_id" --output json | jq -r '.id')

az devops service-endpoint update \
    --id "$sc_id" \
    --enable-for-all "true"