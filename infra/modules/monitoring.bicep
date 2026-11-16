//
// Module monitoring : pour surveiller les ressources
//

param location string
param tags object
param token string


resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
    name: 'log-${token}'
    location: location
    tags: tags
    properties: {
        retentionInDays: 30
        sku: {
            name: 'PerGB2018'
        }
    }
}

resource monitoring 'Microsoft.Insights/components@2020-02-02' = {
    name: 'appinsights-${token}'
    location: location
    tags: tags
    kind: 'web'
    properties: {
        Application_Type: 'web'
        WorkspaceResourceId: workspace.id
    }
}
output name string = monitoring.name
output connectionString string = monitoring.properties.ConnectionString
