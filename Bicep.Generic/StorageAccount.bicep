param Location string = resourceGroup().location
param StorageAccountName string

param StorageAccountVirtualNetworkRules array = []
param StorageAccountIpRules array = []

param StorageAccountSku string = 'Standard_GRS' //Standard_ZRS
param StorageAccountPublicAccessEnabled string = 'Enabled'
param StorageAccountLargeFileShareEnabled string = 'Disabled'
param StorageAccountAccessTier string = 'Hot'

param SolutionName string
param CompanyTag string
param BusinessUnitTag string
param ContactTag string

resource StorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: StorageAccountName
  tags: {
    Solution: SolutionName
    Company: CompanyTag
    'Business Unit': BusinessUnitTag
    Contact: ContactTag
  }
  location: Location
  sku: {
    name: StorageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: StorageAccountPublicAccessEnabled
    allowCrossTenantReplication: false
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    largeFileSharesState: StorageAccountLargeFileShareEnabled
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: StorageAccountVirtualNetworkRules
      ipRules: StorageAccountIpRules
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: StorageAccountAccessTier
  }
}
