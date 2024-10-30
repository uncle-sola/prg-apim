param ServiceBusNamespaceName string
param QueueName string

resource ServiceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: ServiceBusNamespaceName
}

resource MessageArchiveQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: ServiceBusNamespace
  name: QueueName
  properties:{
    deadLetteringOnMessageExpiration: true
  }
}

