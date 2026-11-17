//
// Main : Application DocuMind
//

targetScope = 'subscription'

//@metadata({ azd: { type: 'location' } })
param location string 
param environmentName string 
param principalId string

var token = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName, project: 'documind', enddate: '2026-12-31' }


resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-documind-${environmentName}'
  location: location
  tags: tags
}


module storage 'modules/storage.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    location: location
    tags: tags
    token: token
  }
}

module search 'modules/search.bicep' = {
  name: 'search'
  scope: rg
  params: {
    location: location
    tags: tags
    token: token
  }
}

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    token: token
  }
}

module foundry 'modules/foundry.bicep' = {
  name: 'foundry'
  scope: rg
  params: {
    location: location
    tags: tags
    token: token
    searchServiceName: search.outputs.name
    appInsightsName: monitoring.outputs.name
  }
}

module roles 'modules/roles.bicep' = {
  name: 'roles'
  scope: rg
  params: {
    principalId: principalId
    foundryName: foundry.outputs.accountName
    searchName: search.outputs.name
    storageName: storage.outputs.name
    searchPrincipalId: search.outputs.principalId
    projectPrincipalId: foundry.outputs.projectPrincipalId
  }
}



// Ces sorties deviennent des variables d'environnement azd, puis ton fichier .env
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_AI_PROJECT_ENDPOINT string = foundry.outputs.projectEndpoint
output AZURE_AI_SERVICES_ENDPOINT string = foundry.outputs.servicesEndpoint
output AZURE_OPENAI_ENDPOINT string = foundry.outputs.openAiEndpoint
output CHAT_DEPLOYMENT string = 'gpt-4.1-mini'
output EMBEDDING_DEPLOYMENT string = 'text-embedding-3-small'
output AZURE_SEARCH_ENDPOINT string = search.outputs.endpoint
output SEARCH_CONNECTION_NAME string = foundry.outputs.searchConnectionName
output AZURE_STORAGE_ACCOUNT string = storage.outputs.name
output AZURE_STORAGE_ACCOUNT_ID string = storage.outputs.id
output STORAGE_CONTAINER string = storage.outputs.containerName
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.connectionString
