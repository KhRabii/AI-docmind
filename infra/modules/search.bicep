//
// Module search : pour rechercher les documents  (pdf)
//


param location string
param tags object
param token string

resource search 'Microsoft.Search/searchServices@2023-11-01' = {
    name: 'search-${token}'
    location: location
    tags: tags
    sku: {
        name: 'basic'
    }
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
        replicaCount: 1
        partitionCount: 1
        semanticSearch: 'free'
        authOptions: {
            aadOrApiKey:{
              aadAuthFailureMode: 'http401WithBearerChallenge'
            }
        }
    }
}

output name string = search.name
output id string = search.id 
output principalId string = search.identity.principalId
output endpoint string = 'https://${search.name}.search.windows.net'
