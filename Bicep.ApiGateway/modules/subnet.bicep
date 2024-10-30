@description('Name of the VNET to add a subnet to')
param existingVNETName string

@description('Name of the VNET to add a subnet to')
param apimNetworkResourceGroup string

@description('Name of the nsg')
param nsgName string

@description('Name of the rt')
param routeTableName string

@description('Name of the subnet to add')
param newSubnetName string

@description('Address space of the subnet to add')
param newSubnetAddressPrefix string = '10.0.0.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: existingVNETName
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' existing = {
  name: nsgName
  scope: resourceGroup(apimNetworkResourceGroup)
}

resource rt 'Microsoft.Network/routeTables@2023-04-01' existing = {
  name: routeTableName
  scope: resourceGroup(apimNetworkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' = {
  parent: vnet
  name: newSubnetName
  properties: {
    addressPrefix: newSubnetAddressPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
      }
      {
        service: 'Microsoft.ServiceBus'
      }
      {
        service: 'Microsoft.Sql'
      }
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.Web'
      }
      {
        service: 'Microsoft.EventHub'
      }
    ]
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    networkSecurityGroup: {
      id: nsg.id
    }
    routeTable:{
      id: rt.id
    }
  }
}
