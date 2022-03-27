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
set -o xtrace # For debugging

###################
# REQUIRED ENV VARIABLES:
#
# PROJECT
# AZURE_REPO
# AZDO_PIPELINES_BRANCH_NAME
# DEV_DATAFACTORY_NAME

createPipeline () {
    declare pipeline_name=$1
    declare pipeline_description=$2
    full_pipeline_name=$PROJECT-$pipeline_name
    pipeline_id=$(az pipelines create \
        --name "$full_pipeline_name" \
        --description "$pipeline_description" \
        --repository-type tfsgit \
        --repository "$AZURE_REPO" \
        --branch "$AZDO_PIPELINES_BRANCH_NAME" \
        --yaml-path "/devops/azure-pipelines-$pipeline_name.yml" \
        --skip-first-run true \
        --output json | jq -r '.id')
    echo "$pipeline_id"
}

# Build Pipelines
createPipeline "ci-qa-python" "This pipeline runs python unit tests and linting."
createPipeline "ci-artifacts" "This pipeline publishes build artifacts"

# Release Pipelines
cd_release_pipeline_id=$(createPipeline "cd-release" "This pipeline releases across environments")

az pipelines variable create \
    --name devAdfName \
    --pipeline-id "$cd_release_pipeline_id" \
    --value "$DEV_DATAFACTORY_NAME"