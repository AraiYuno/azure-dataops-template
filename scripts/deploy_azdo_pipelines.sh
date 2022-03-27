#!/bin/bash

# Access granted under MIT Open Source License: https://en.wikipedia.org/wiki/MIT_License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, # and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions 
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.


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