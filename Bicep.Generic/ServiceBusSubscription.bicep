param ServiceBusNamespaceName string
param ServiceBusTopicName string
param ServiceBusSubscriptionName string

param ServiceBusMessageLockDuration string = 'PT60S' // 60 seconds
param ServiceBusDefaultMessageTimeToLive string = 'P14D' // 14 days
param ServiceBusMaxDeliveryCount int = 10
param ServiceBusAutoDeleteOnIdle string = 'P10675198DT2H48M5.477S' // ~29227 years
param ServiceBusDeadLetteringOnMessageExpiration bool = false


resource ServiceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: ServiceBusNamespaceName
}

resource ServiceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' existing = {
  parent: ServiceBusNamespace
  name: ServiceBusTopicName
}

resource ServiceBusTopicSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-01-01-preview' = {
  parent: ServiceBusTopic
  name: ServiceBusSubscriptionName
  properties: {
    //isClientAffine: false
    lockDuration: ServiceBusMessageLockDuration
    //requiresSession: false
    defaultMessageTimeToLive: ServiceBusDefaultMessageTimeToLive
    deadLetteringOnMessageExpiration: ServiceBusDeadLetteringOnMessageExpiration
    deadLetteringOnFilterEvaluationExceptions: false
    maxDeliveryCount: ServiceBusMaxDeliveryCount
    status: 'Active'
    //enableBatchedOperations: true
    autoDeleteOnIdle: ServiceBusAutoDeleteOnIdle
  }
}
