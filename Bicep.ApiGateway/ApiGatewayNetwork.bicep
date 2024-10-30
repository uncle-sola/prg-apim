param Location string = resourceGroup().location

param ExistingVnetName string
param ExistingVnetRG string
param ExistingVnetSubscription string
param subnet01Range string
param subnet02Range string
param subnet01Name string
param subnet02Name string
param routeTableName string
param virtualApplianceIp string
param nsg1Name string
param nsg2Name string
param apimPublicIp string

param BusinessUnitTag string = 'New Business Unit'
param CompanyTag string = 'Connells Group'
param ContactTag string = 'Dev - Online'
param SolutionName string = 'ApiGatewayNetwork'
param Timestamp string = utcNow('yyyyMMdd-HHmmss')

var tags = {
  Solution: SolutionName
  Company: CompanyTag
  'Business Unit': BusinessUnitTag
  Contact: ContactTag
}

module apimIPAddress './modules/PublicIPAddress.bicep' = {
  name: '${Timestamp}-apimIPAddress'
  params: {
    publicIPAddress_name: apimPublicIp
    publicIPAddress_name_domain: toLower(apimPublicIp)
    tags: tags
    location: Location
    publicipfqdn: '${toLower(apimPublicIp)}.azure-api.net'
    }
 
}

module RouteTable './modules/RouteTable.bicep' = {
  name: '${Timestamp}-RouteTable'
  params: {
    rtName: routeTableName
    location: Location
    apimPublicIp: apimIPAddress.outputs.ipAddress
    tags: tags
    virtualApplianceIp: virtualApplianceIp
    createDefaultRoute: true
  }
  dependsOn:[
    apimIPAddress
  ]
}


module APIMNSG1Rules './modules/APIMSubnetNSGRules.bicep' = {
  name: '${Timestamp}-APIMNSG1Rules'
  params: {
    apimSubnetNsg: true
    nsgName: nsg1Name
    tags: tags
    location: Location
  }
}

module APIMNSG2Rules './modules/APIMSubnetNSGRules.bicep' = {
  name: '${Timestamp}-APIMNSG2Rules'
  params: {
    apimSubnetNsg: false
    nsgName: nsg2Name
    tags: tags
    location: Location
  }
}

module Subnet1 './modules/subnet.bicep' = {
  name: '${Timestamp}-subnet1'
  scope: resourceGroup(subscription().subscriptionId,ExistingVnetRG)
  params: {
    existingVNETName: ExistingVnetName
    apimNetworkResourceGroup: resourceGroup().name
    nsgName: nsg1Name
    newSubnetName: subnet01Name
    newSubnetAddressPrefix: subnet01Range
    routeTableName: routeTableName
  }
  dependsOn:[
    APIMNSG1Rules
    APIMNSG2Rules
    RouteTable
  ]
}


module Subnet2 './modules/subnet.bicep' = {
  name: '${Timestamp}-subnet2'
  scope: resourceGroup(ExistingVnetSubscription, ExistingVnetRG)
  params: {
    existingVNETName: ExistingVnetName
    apimNetworkResourceGroup: resourceGroup().name
    newSubnetName: subnet02Name
    newSubnetAddressPrefix: subnet02Range
    nsgName: nsg2Name
    routeTableName: routeTableName
  }
  dependsOn:[
    Subnet1
  ]
}
