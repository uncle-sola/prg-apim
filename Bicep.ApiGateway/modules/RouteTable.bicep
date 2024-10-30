@description('location')
param location string = resourceGroup().location

@description('Name of the route table')
param rtName string

@description('Virtuaal appliance IP')
param virtualApplianceIp string

@description('asset tags')
param tags object

@description('create default route?')
param createDefaultRoute bool = true

@description('APIM Public IP')
param apimPublicIp string



@description('default route')
var defaultRoute = {
  routes: [
    {
      name: 'APIMControlPlane'
      properties: {
        addressPrefix: 'ApiManagement'
        nextHopType: 'Internet'
      }
    }
    {
      name: 'APIMControlPlaneIp'
      properties: {
        addressPrefix: '${apimPublicIp}/32'
        nextHopType: 'Internet'
      }
    }
    {
      name: 'Default'
      properties: {
        addressPrefix: '0.0.0.0/0'
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: virtualApplianceIp
      }
    }
  ]
}

@description('default route properties')
var routeProperties = {
  disableBgpRoutePropagation: true
}


resource RouteTable 'Microsoft.Network/routeTables@2023-04-01' = {
  name: rtName
  location: location
  properties: createDefaultRoute ? union(defaultRoute, routeProperties) : routeProperties
  tags: tags
}

