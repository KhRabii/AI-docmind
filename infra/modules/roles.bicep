//
// Module Foundry : Coeur Application DocuMind
//

param principalId string          // ton identité (fournie par azd)
param foundryName string
param searchName string
param storageName string
param searchPrincipalId string    // identité managée de Search
param projectPrincipalId string   // identité managée du projet Foundry


var roles = {
  azureAIUser: '53ca6127-db72-4b80-b1b0-d745d6d5456d'
  cognitiveServicesUser: 'a97b65f3-24c7-4388-baec-2e87135dc908'
  cognitiveServicesOpenAIUser: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
  searchIndexDataContributor: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
  searchIndexDataReader: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
  searchServiceContributor: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
  storageBlobDataContributor: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  storageBlobDataReader: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

resource foundry 'Microsoft.CognitiveServices/accounts@2025-06-01' existing = { name: foundryName }
resource search 'Microsoft.Search/searchServices@2023-11-01' existing = { name: searchName }
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = { name: storageName }

var assignments = [
  // --- Toi ---
  { scope: 'foundry', principal: principalId, role: roles.azureAIUser, type: 'User' }
  { scope: 'foundry', principal: principalId, role: roles.cognitiveServicesUser, type: 'User' }
  { scope: 'search', principal: principalId, role: roles.searchIndexDataContributor, type: 'User' }
  { scope: 'search', principal: principalId, role: roles.searchServiceContributor, type: 'User' }
  { scope: 'storage', principal: principalId, role: roles.storageBlobDataContributor, type: 'User' }
  // --- Identité de Search ---
  { scope: 'storage', principal: searchPrincipalId, role: roles.storageBlobDataReader, type: 'ServicePrincipal' }
  { scope: 'foundry', principal: searchPrincipalId, role: roles.cognitiveServicesOpenAIUser, type: 'ServicePrincipal' }
  // --- Identité du projet ---
  { scope: 'search', principal: projectPrincipalId, role: roles.searchIndexDataReader, type: 'ServicePrincipal' }
  { scope: 'search', principal: projectPrincipalId, role: roles.searchServiceContributor, type: 'ServicePrincipal' }
]

resource foundryRoles 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for a in filter(assignments, x => x.scope == 'foundry'): {
  name: guid(foundry.id, a.principal, a.role)
  scope: foundry
  properties: {
    principalId: a.principal
    principalType: a.type
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', a.role)
  }
}]

resource searchRoles 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for a in filter(assignments, x => x.scope == 'search'): {
  name: guid(search.id, a.principal, a.role)
  scope: search
  properties: {
    principalId: a.principal
    principalType: a.type
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', a.role)
  }
}]

resource storageRoles 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for a in filter(assignments, x => x.scope == 'storage'): {
  name: guid(storage.id, a.principal, a.role)
  scope: storage
  properties: {
    principalId: a.principal
    principalType: a.type
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', a.role)
  }
}]
