//
// Module Foundry : Coeur Application DocuMind
//

param location string
param tags object
param token string
param chatDeploymentName string = 'gpt-4.1-mini'
param embeddingDeploymentName string = 'text-embedding-3-small'
param searchServiceName string
param appInsightsName string


var accountName = 'aif-${token}'
var projectName = 'documind'


resource account 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
    name: accountName
    location: location
    tags: tags
    kind: 'AIServices'
    sku: {
        name: 'S0'
    }
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        customSubDomainName: accountName
        allowProjectManagement: true
        disableLocalAuth: true
        publicNetworkAccess: 'Enabled'
    }
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
    parent: account
    name: projectName
    location: location
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        description: 'Project for DocuMind'
    }
}

resource chat 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = {
    parent: account
    name: chatDeploymentName
    sku: {
        name: 'GlobalStandard'
        capacity: 30
    }
    properties: {
        model: {
          format: 'OpenAI', name: 'gpt-4.1-mini', version: '2025-04-14'
        }
        versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    }
    dependsOn: [ project ]
}

resource embedding 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = {
    parent: account
    name: embeddingDeploymentName
    sku: { name: 'GlobalStandard', capacity: 30 }
    properties: {
        model: { format: 'OpenAI', name: 'text-embedding-3-small', version: '1' }
    }
    dependsOn: [ chat ]
}

resource search 'Microsoft.Search/searchServices@2023-11-01' existing = {
    name: searchServiceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
    name: appInsightsName
}

resource searchConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01' = {
    parent: project
    name: 'search'
    properties: {
      category: 'CognitiveSearch'
      target: 'https://${search.name}.search.windows.net'
      authType: 'AAD'
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: search.id
        location: search.location
      }
    }
}

resource appInsightsConnection 'Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01' = {
    parent: project
    name: 'appinsights'
    properties: {
        category: 'AppInsights'
        target: appInsights.id
        authType: 'ApiKey'
        isSharedToAll: true
        credentials: { key: appInsights.properties.ConnectionString }
        metadata: { ApiType: 'Azure', ResourceId: appInsights.id }  
    }
}


output accountName string = account.name
output projectEndpoint string = 'https://${accountName}.services.ai.azure.com/api/projects/${projectName}'
output servicesEndpoint string = 'https://${accountName}.cognitiveservices.azure.com/'
output openAiEndpoint string = 'https://${accountName}.openai.azure.com/'
output projectPrincipalId string = project.identity.principalId
output searchConnectionName string = searchConnection.name
