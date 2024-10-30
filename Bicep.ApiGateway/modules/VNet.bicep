@description('location')
param location string = resourceGroup().location

@description('Name of the VNet')
param vNetName string

@description('Address')
param addressPrefix string

@description('asset tags')
param tags object


resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vNetName
  tags: tags
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: []
    virtualNetworkPeerings: []
    enableDdosProtection: false
    enableVmProtection: false
  }
}
