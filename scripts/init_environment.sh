#!/bin/bash

# check required variables are specified.
GITHUB_REPO="https://price-industries@dev.azure.com/price-industries/Data%20Management/_git/anvil-data-infrastructure-data-services"
GITHUB_PAT_TOKEN="egsdurs4lgp27xghqwazowqqpzb22wmphudni5yp5k6dbsdq4hya"
AZDO_PROJECT="Data Management"
AZURE_LOCATION="eastus2"
AZURE_SUBSCRIPTION_ID="48fa33af-e847-429c-9400-c93a7d3d8f47"
AZDO_PIPELINES_BRANCH_NAME="prod"
AZURESQL_SERVER_PASSWORD="Z6MK9SzWG2Qk4EncU5Evtju4BdfkaVYThYybwWtFXAKFhXkE5ewc7vqNS4X9hfbh"
SYNAPSE_SQL_PASSWORD="Z6MK9SzWG2Qk4EncU5Evtju4BdfkaVYThYybwWtFXAKFhXkE5ewc7vqNS4X9hfbh"
DEPLOYMENT_ID="dinfra"

# if [ -z "$GITHUB_REPO" ]
# then 
#     echo "Please specify a github repo using the GITHUB_REPO environment variable in this form '<my_github_handle>/<repo>'. (ei. 'devlace/mdw-dataops-import')"
#     exit 1
# fi

DEPLOYMENT_ID=${DEPLOYMENT_ID:-}
if [ -z "$DEPLOYMENT_ID" ]
then 
    export DEPLOYMENT_ID="$(random_str 5)"
    echo "No deployment id [DEPLOYMENT_ID] specified, defaulting to $DEPLOYMENT_ID"
fi