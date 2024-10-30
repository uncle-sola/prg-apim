param Location string = resourceGroup().location

param LogAnalyticsName string
param AppInsightsName string
param StorageAccountName string
param ManagedIdentityStorageContributorName string
param vaultName string

param BusinessUnitTag string = 'New Business Unit'
param CompanyTag string = 'Connells Group'
param ContactTag string = 'Dev - Online'
param SolutionName string = 'ApiGateway'
param StorageAccountContributorRoleId string = '17d1049b-9a84-46fb-8f53-869881c3d3ab'
param Timestamp string = utcNow('yyyyMMdd-HHmmss')

param ExistingVnetName string
param ExistingVnetRG string
param ExistingVnetSubscription string
param subnet02Name string

var tags= {
  Solution: SolutionName
  Company: CompanyTag
  'Business Unit': BusinessUnitTag
  Contact: ContactTag
}

var enablePublicAccess = true

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  scope: resourceGroup(ExistingVnetSubscription,ExistingVnetRG)
  name: ExistingVnetName
}

resource NewStorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing =  {
  name: StorageAccountName
}

module LogAnalytics '../Bicep.Generic/LogAnalytics.bicep' = {
  name: '${Timestamp}-${LogAnalyticsName}'
  params: {
    BusinessUnitTag: BusinessUnitTag
    CompanyTag: CompanyTag
    ContactTag: ContactTag
    Location: Location
    LogAnalyticsName: LogAnalyticsName
    SolutionName: SolutionName
  }
}

module AppInsights '../Bicep.Generic/AppInsights.bicep' = {
  name: '${Timestamp}-${AppInsightsName}'
  params: {
    AppInsightsName: AppInsightsName
    BusinessUnitTag: BusinessUnitTag
    CompanyTag: CompanyTag
    ContactTag: ContactTag
    Location: Location
    LogAnalyticsId: LogAnalytics.outputs.Id
    SolutionName: SolutionName
  }
}


module StorageAccount '../Bicep.Generic/StorageAccount.bicep' = {
  name: '${Timestamp}-${StorageAccountName}'
  params: {
    StorageAccountName: StorageAccountName
    StorageAccountSku: 'Standard_ZRS'
    BusinessUnitTag: BusinessUnitTag
    CompanyTag: CompanyTag
    ContactTag: ContactTag
    SolutionName: SolutionName
    StorageAccountPublicAccessEnabled: 'Enabled'
  }
}


module StorageAccountBlobService '../Bicep.Generic/StorageAccountBlobService.bicep' = {
  name: '${StorageAccount.name}-blob'
  params: {
    StorageAccountBlobName: 'default'
    StorageAccountName: StorageAccountName
  }
}


module StorageAccountContributorRoleAssignment '../Bicep.Generic/RoleAssignmentSingle.bicep' = {
  name: '${Timestamp}-RoleAssignment'
  params: {
    PrincipalId: ManagedIdentityStorageContributor.outputs.PrincipalId
    RoleDefinitionId: StorageAccountContributorRoleId
  }
}

module ManagedIdentityStorageContributor '../Bicep.Generic/UserAssignedManagedIdentity.bicep' = {
  name: '${Timestamp}-${ManagedIdentityStorageContributorName}'
  params: {
    BusinessUnitTag: BusinessUnitTag 
    CompanyTag: CompanyTag
    ContactTag: ContactTag
    ManagedIdentityName: ManagedIdentityStorageContributorName
    SolutionName: SolutionName
  }
}

module KeyVault './modules/Keyvault.bicep' = {
  name: '${Timestamp}-vault'
  params: {
    vaultName: vaultName
    sku: {
      name: 'Standard'
      family: 'A'
    }
    enablePublicAccess: enablePublicAccess
    tags: tags
  }
}


module DiagSetting './modules/keyvault-diag.bicep' = {
  name: '${Timestamp}-diag-setting'
  params: {
    auditStorageAccountName: StorageAccountName
    laWorkspaceName: LogAnalyticsName
    vaultName: vaultName
  }
  dependsOn:[
    KeyVault
    StorageAccount
    LogAnalytics
  ]
}

module keyVaultPrivateEndpoint './modules/PrivateEndpoint.bicep' = if (!(enablePublicAccess)) {
  name: '${Timestamp}-keyVaultPrivateEndpoint'
  params: {
    tags: tags
    location: Location
    groupName: 'vault'
    privateEndpointName: '${vaultName}-PE'
    resourceId: KeyVault.outputs.Id
    subnetResourceId: '${vnet.id}/subnets/${subnet02Name}'
  }
  dependsOn:[
    KeyVault
  ]
}

module StorageAccountEndpoint './modules/PrivateEndpoint.bicep' = if (!(enablePublicAccess)) {
  name: '${Timestamp}-StorageAccountEndpoint'
  params: {
    tags: tags
    location: Location
    groupName: 'blob'
    privateEndpointName: '${StorageAccountName}-PE'
    resourceId: NewStorageAccount.id
    subnetResourceId: '${vnet.id}/subnets/${subnet02Name}'
  }
  dependsOn:[
    StorageAccount
    DiagSetting
  ]
}
