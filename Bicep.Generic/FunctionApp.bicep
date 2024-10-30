param Location string = resourceGroup().location
param FunctionAppName string
param AppServicePlanName string
param AppInsightsName string
param FunctionStorageAccountName string
param FunctionStorageAccountResourceGroupName string
param FunctionAppUserAssignedIdentities object = {}
var UserAssignedIdentitiesIDLookup = sort(map(range(0, length(union({ userAssignedIdentities: []}, FunctionAppUserAssignedIdentities).userAssignedIdentities)), i => {
  id: resourceId(union({
    subscriptionId: subscription().subscriptionId
  }, FunctionAppUserAssignedIdentities.userAssignedIdentities[i]).subscriptionId, union({
    resourceGroupName: resourceGroup().name
  }, FunctionAppUserAssignedIdentities.userAssignedIdentities[i]).resourceGroupName, 'Microsoft.ManagedIdentity/userAssignedIdentities', FunctionAppUserAssignedIdentities.userAssignedIdentities[i].name)
  index: i
}), (x, y) => (x.index < y.index))
@allowed([
  'v8.0'
  'v6.0'
])
param FunctionAppNetFrameworkVersion string = 'v6.0'
param SolutionName string
param CompanyTag string
param BusinessUnitTag string
param ContactTag string

resource AppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: AppServicePlanName
}

resource AppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: AppInsightsName
}

resource FunctionStorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  scope: resourceGroup(FunctionStorageAccountResourceGroupName)
  name: FunctionStorageAccountName
}

resource FunctionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: FunctionAppName
  location: Location
  kind: 'functionapp'
  tags: {
    Solution: SolutionName
    Company: CompanyTag
    'Business Unit': BusinessUnitTag
    Contact: ContactTag
  }
  identity: empty(FunctionAppUserAssignedIdentities) ? null : {
    type: union({ type: (empty(UserAssignedIdentitiesIDLookup) ? null : 'UserAssigned') }, FunctionAppUserAssignedIdentities).type
    userAssignedIdentities: (empty(UserAssignedIdentitiesIDLookup) ? null : reduce(UserAssignedIdentitiesIDLookup, {}, (x, y) => union(x, { '${y.id}': {} })))
  }
  properties: {
    serverFarmId: AppServicePlan.id
    httpsOnly: true
    scmSiteAlsoStopped: false
    
    siteConfig: {
      netFrameworkVersion: FunctionAppNetFrameworkVersion
      vnetRouteAllEnabled: true
      minTlsVersion: '1.2'
      http20Enabled: true
      alwaysOn: true
      use32BitWorkerProcess: false
      metadata: [{
          name: 'CURRENT_STACK'
          value: 'dotnet'
      }]
      appSettings: [{
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: AppInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: AppInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${FunctionStorageAccount.name};AccountKey=${FunctionStorageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
      ] 
    }
  }
}

resource PublishingCredentialsPolicyScm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  name: 'scm'
  kind: 'string'
  parent: FunctionApp
  properties: {
    allow: true
  }
}

resource symbolicname 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  name: 'ftp'
  kind: 'string'
  parent: FunctionApp
  properties: {
    allow: false
  }
}

output Id string = FunctionApp.id
output DefaultUrl string = FunctionApp.properties.hostNames[0]
