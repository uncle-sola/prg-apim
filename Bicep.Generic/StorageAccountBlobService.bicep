param StorageAccountName string
param StorageAccountBlobName string

param BlobDeleteRetentionDays int = 7
param ContainerDeleteRetentionDays int = 7

param CorsRules array = []

resource StorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: StorageAccountName
}

resource StorageAccountBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: StorageAccount
  name: StorageAccountBlobName
  properties: {
    cors: {
      corsRules: CorsRules
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: BlobDeleteRetentionDays
    }
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: false
      days: ContainerDeleteRetentionDays
      enabled: true
    }
  }
}
