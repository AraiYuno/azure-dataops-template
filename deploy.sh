set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace # For debugging

. ./scripts/common.sh
. ./scripts/verify_prerequisites.sh
. ./scripts/init_environment.sh


project=anvil-dm # CONSTANT
###################
# DEPLOY ALL FOR EACH ENVIRONMENT

# for env_name in dev stg prod; do  # dev stg prod
#     PROJECT=$project \
#     ENV_NAME=$env_name \
#     AZURE_LOCATION=$AZURE_LOCATION \
#     AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID \
#     AZURESQL_SERVER_PASSWORD=$AZURESQL_SERVER_PASSWORD \
#     bash -c "./scripts/deploy_infrastructure.sh"  # inclues AzDevOps Azure Service Connections and Variable Groups
# done


###################
# Deploy AzDevOps Pipelines

# azure-pipelines-cd-release.yml pipeline require DEV_DATAFACTORY_NAME set, retrieve this value from .env.dev file
declare DEV_"$(grep -e '^DATAFACTORY_NAME' .env.dev | tail -1 | xargs)"

# Deploy all pipelines
PROJECT=$project \
AZURE_REPO=$AZURE_REPO \
AZDO_PIPELINES_BRANCH_NAME=$AZDO_PIPELINES_BRANCH_NAME \
DEV_DATAFACTORY_NAME=$DATAFACTORY_NAME \
    bash -c "./scripts/deploy_azdo_pipelines.sh"

####

print_style "DEPLOYMENT SUCCESSFUL
Details of the deployment can be found in local .env.* files.\n\n" "success"

print_style "IMPORTANT:
This script has updated your local Azure Pipeline YAML definitions to point to your Github repo.
ACTION REQUIRED: Commit and push up these changes to your Github repo before proceeding.\n\n" "warning"

echo "Author: Kyle Ahn. pyh2982@gmail.com" 