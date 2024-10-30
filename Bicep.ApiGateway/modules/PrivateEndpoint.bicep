@description('name of private endpoint')
param privateEndpointName string

@description('location')
param location string = resourceGroup().location

@description('resource id of the resource you want to protect witha private endpoint')
param resourceId string

@description('group name')
param groupName string

@description('resource Id of the subnet')
param subnetResourceId string

@description('tags')
param tags object

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: resourceId
          groupIds: [
            groupName
          ]
        }
      }
    ]
    subnet: {
      id: subnetResourceId
    }
    customDnsConfigs: []
  }
}
