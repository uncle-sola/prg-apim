param Location string = resourceGroup().location
param VnetName string
param addressPrefix string


param BusinessUnitTag string = 'New Business Unit'
param CompanyTag string = 'Connells Group'
param ContactTag string = 'Dev - Online'
param SolutionName string = 'ApiGateway'
param Timestamp string = utcNow('yyyyMMdd-HHmmss')

var tags= {
  Solution: SolutionName
  Company: CompanyTag
  'Business Unit': BusinessUnitTag
  Contact: ContactTag
}

module VNet './modules/VNet.bicep' = {
  name: '${Timestamp}-vnet'
  params:{
    vNetName: VnetName
    tags: tags
    addressPrefix: addressPrefix
    location: Location
  }
  dependsOn:[

  ]
}
