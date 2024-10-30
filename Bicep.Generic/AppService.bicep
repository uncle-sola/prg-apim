param Location string = resourceGroup().location
param AppServiceUserAssignedIdentities object = {}
var UserAssignedIdentitiesIDLookup = sort(map(range(0, length(union({ userAssignedIdentities: []}, AppServiceUserAssignedIdentities).userAssignedIdentities)), i => {
  id: resourceId(union({
    subscriptionId: subscription().subscriptionId
  }, AppServiceUserAssignedIdentities.userAssignedIdentities[i]).subscriptionId, union({
    resourceGroupName: resourceGroup().name
  }, AppServiceUserAssignedIdentities.userAssignedIdentities[i]).resourceGroupName, 'Microsoft.ManagedIdentity/userAssignedIdentities', AppServiceUserAssignedIdentities.userAssignedIdentities[i].name)
  index: i
}), (x, y) => (x.index < y.index))
@allowed([
  'v8.0'
  'v6.0'
])
param AppServiceNetFrameworkVersion string = 'v6.0'
param SolutionName string
param AppServiceName string
param AppServicePlanName string
param AppInsightsName string
param CompanyTag string
param BusinessUnitTag string
param ContactTag string

resource AppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: AppInsightsName
}

resource AppServicePlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: AppServicePlanName
}

resource AppService 'Microsoft.Web/sites@2022-09-01' = {
  name: AppServiceName
  location: Location
  kind: 'app'
  tags: {
    Solution: SolutionName
    Company: CompanyTag
    'Business Unit': BusinessUnitTag
    Contact: ContactTag
  }
  identity: empty(AppServiceUserAssignedIdentities) ? null : {
    type: union({ type: (empty(UserAssignedIdentitiesIDLookup) ? null : 'UserAssigned') }, AppServiceUserAssignedIdentities).type
    userAssignedIdentities: (empty(UserAssignedIdentitiesIDLookup) ? null : reduce(UserAssignedIdentitiesIDLookup, {}, (x, y) => union(x, { '${y.id}': {} })))
  }
  properties: {
    //virtualNetworkSubnetId: Subnet.id
    serverFarmId: AppServicePlan.id
    httpsOnly: true
    siteConfig: {
      vnetRouteAllEnabled: true
      alwaysOn: true
      minTlsVersion: '1.2'
      http20Enabled: true
      netFrameworkVersion: AppServiceNetFrameworkVersion
      metadata: [{
          name: 'CURRENT_STACK'
          value: 'dotnet'
      }]
     appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: AppInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: AppInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }] 
    }
  }
}

resource PublishingCredentialsPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  name: 'scm'
  kind: 'string'
  parent: AppService
  properties: {
    allow: true
  }
}

output Id string = AppService.id
output DefaultUrl string = AppService.properties.hostNames[0]
