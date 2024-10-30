param vaultName string
param auditStorageAccountName string
param laWorkspaceName string

resource laWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: laWorkspaceName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  name: auditStorageAccountName       // Required 
}

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: vaultName       // Required 
}

resource keyVaultName_audit_setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vaultName}-audit-settings'
  scope: keyvault
  properties: {
    storageAccountId: storageAccount.id
    workspaceId: laWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

