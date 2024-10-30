param ServiceBusNamespaceName string
param ServiceBusTopicName string

param ServiceBusTopicMaxSizeInMegabytes int = 1024
param ServiceBusTopicDefaultMessageTimeToLive string = 'P14D' // 14 days
param ServiceBusTopicAutoDeleteOnIdle string = 'P10675198DT2H48M5.477S'
param ServiceBusTopicSupportOrdering bool = false

resource ServiceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: ServiceBusNamespaceName
}

resource ServiceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  parent: ServiceBusNamespace
  name: ServiceBusTopicName
  properties: {
    maxSizeInMegabytes: ServiceBusTopicMaxSizeInMegabytes
    defaultMessageTimeToLive: ServiceBusTopicDefaultMessageTimeToLive
    autoDeleteOnIdle: ServiceBusTopicAutoDeleteOnIdle
    supportOrdering: ServiceBusTopicSupportOrdering
  }
}
