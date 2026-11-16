//
// Module storage : pour sauvegarder les documents  (pdf)
//

param location string
param tags object
param token string

var containerName = 'docs'
var archiveContainerName = 'archive'


resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
    name: 'str${token}'
    location: location
    tags: tags
    kind: 'StorageV2'
    sku: {
        name: 'Standard_LRS'
    }
    properties: {
        minimumTlsVersion: 'TLS1_2'
        allowBlobPublicAccess: false
        allowSharedKeyAccess: false
    }
}


resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
    parent: storage
    name: 'default'
    properties: {
        deleteRetentionPolicy: {
            enabled: true
            days: 7
        }
    }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
    parent: blobService
    name: containerName
}



resource containerArchive 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
    parent: blobService
    name: archiveContainerName
}

output name string = storage.name
output id string = storage.id
output containerName string = container.name
output archiveContainerName string = containerArchive.name
