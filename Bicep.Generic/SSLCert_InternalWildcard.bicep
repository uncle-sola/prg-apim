param KeyVaultResourceGroupName string
param KeyVaultName string
param KeyVaultSubscriptionId string
param AppServicePlanName string
param Location string 

var CertificateName = 'branch-local-internal-wildcard'

resource AppServicePlan 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: AppServicePlanName
}

resource KeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: KeyVaultName
  scope: resourceGroup(KeyVaultSubscriptionId, KeyVaultResourceGroupName )
}

resource SSLCert 'Microsoft.Web/certificates@2018-02-01' = {
  name: CertificateName
  location: Location
  properties: {
    keyVaultId: KeyVault.id
    keyVaultSecretName: CertificateName
    serverFarmId: AppServicePlan.id
    password: '' // Property is mandatory but value is redundant...
  }
}

output Thumbprint string = SSLCert.properties.thumbprint
