param project string = 'mdwdo'
param env string = 'dev'
param location string = resourceGroup().location
param keyvault_owner_object_id string

module datafactory './modules/datafactory.bicep' = {
  name: 'datafactory_deploy'
  params: {
    project: project
    env: env
    location: location
  }
}

module databricks './modules/databricks.bicep' = {
  name: 'databricks_deploy'
  params: {
    project: project
    env: env
    location: location
    contributor_principal_id: datafactory.outputs.datafactory_principal_id
  }
}

module storage './modules/storage.bicep' = {
  name: 'storage_deploy'
  params: {
    project: project
    env: env
    location: location
    contributor_principal_id: datafactory.outputs.datafactory_principal_id
  }
}

module keyvault './modules/keyvault.bicep' = {
  name: 'keyvault_deploy'
  params: {
    project: project
    env: env
    location: location
    keyvault_owner_object_id: keyvault_owner_object_id
    datafactory_principal_id: datafactory.outputs.datafactory_principal_id
  }

  dependsOn: [
    datafactory
  ]
}

module appinsights './modules/appinsights.bicep' = {
  name: 'appinsights_deploy'
  params: {
    project: project
    env: env
    location: location
  }
}


output storage_account_name string = storage.outputs.storage_account_name
output databricks_output object = databricks.outputs.databricks_output
output databricks_id string = databricks.outputs.databricks_id
output appinsights_name string = appinsights.outputs.appinsights_name
output keyvault_name string = keyvault.outputs.keyvault_name
output keyvault_resource_id string = keyvault.outputs.keyvault_resource_id
output datafactory_name string = datafactory.outputs.datafactory_name
