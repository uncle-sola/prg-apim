param Location string = resourceGroup().location
param ServiceBusNamespaceName string
param ServiceBusSku string = 'Standard'
param ServiceBusDisableLocalAuth bool = false
param ServiceBusPublicNetworkAccess string = 'Enabled'

param SolutionName string
param CompanyTag string
param BusinessUnitTag string
param ContactTag string

resource ServiceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: ServiceBusNamespaceName
  location: Location
  sku: {
    name: ServiceBusSku
    tier: ServiceBusSku
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: ServiceBusPublicNetworkAccess
    disableLocalAuth: ServiceBusDisableLocalAuth
    zoneRedundant: false
  }
  tags: {
    Solution: SolutionName
    Company: CompanyTag
    'Business Unit': BusinessUnitTag
    Contact: ContactTag
  }
}
