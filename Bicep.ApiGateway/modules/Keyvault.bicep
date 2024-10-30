@description('location')
param location string = resourceGroup().location

@description('Name of the vault')
param vaultName string

@description('Vault sku')
param sku object = {
  name: 'standard'
  family: 'A'  
}

@description('enable public access to vault, defaults to true')
param enablePublicAccess bool = false

param networkAclsDefaultAction string = 'Deny'
param virtualNetworkRules array = []

@description('enable RBAC authorization')
param enableRbacAuthorization bool = true

@description('Access policies, no longer in vogue')
param accessPolicies array = []

@description('Enable soft Delete')
param enableSoftDelete bool = true

@description('enable purge protection')
param enablePurgeProtection bool = true

@description('asset tags')
param tags object

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: vaultName
  location: location
  tags: tags
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: enableSoftDelete
    enablePurgeProtection: enablePurgeProtection
    tenantId: tenant().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: networkAclsDefaultAction
      virtualNetworkRules: virtualNetworkRules
    }
    publicNetworkAccess: (enablePublicAccess ? 'Enabled' : 'Disabled')
    accessPolicies: enableRbacAuthorization ? [] : accessPolicies
    sku: sku
    enableRbacAuthorization: enableRbacAuthorization
  }
}

output Id string = keyVault.id
