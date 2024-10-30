@description('Is it APIM Subnet NSG')
param apimSubnetNsg bool

@description('location')
param location string = resourceGroup().location

@description('Name of the nsg')
param nsgName string

@description('asset tags')
param tags object

var priorityOffset = 306

var defaultRules = {
  rules: [
    {
      name: 'ApiInbound'
      properties: {
        description: 'Management endpoint for Azure portal and PowerShell'
        protocol: 'TCP'
        sourcePortRange: '*'
        destinationPortRange: '443'
        sourceAddressPrefix: 'ApiManagement'
        destinationAddressPrefix: 'VirtualNetwork'
        access: 'Allow'
        priority: 130
        direction: 'Inbound'
      }
    }
  ]
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: defaultRules.rules
  }
}

resource AllowAPIManagement443Internet 'Microsoft.Network/networkSecurityGroups/securityRules@2023-04-01' = if (apimSubnetNsg) {
  parent: nsg
  name: 'allow-internet-apim'
  properties: {
    access: 'Allow'
    description: 'Allow traffic from Internet to apim'
    destinationAddressPrefix: 'VirtualNetwork'
    destinationPortRange: '443'

    direction: 'Inbound'
    priority: priorityOffset + 1
    protocol: 'TCP'
    sourceAddressPrefix: 'Internet'
    sourcePortRange: '*'
  }
}

resource AllowAPIManagement3443Vnet 'Microsoft.Network/networkSecurityGroups/securityRules@2023-04-01' = if (apimSubnetNsg) {
  parent: nsg
  name: 'allow-apim-apim'
  properties: {
    access: 'Allow'
    description: 'Allow traffic from apiManagement endpoint to vnet'
    destinationAddressPrefix: 'VirtualNetwork'

    destinationPortRange: '3443'

    direction: 'Inbound'
    priority: priorityOffset + 2
    protocol: '*'
    sourceAddressPrefix: 'ApiManagement'
    sourcePortRange: '*'
  }
}

resource AllowAPIManagement6390Vnet 'Microsoft.Network/networkSecurityGroups/securityRules@2023-04-01' = if (apimSubnetNsg) {
  parent: nsg
  name: 'allow-apim-loadbalancer'
  properties: {
    access: 'Allow'
    description: 'Allow traffic from load balancer endpoint to vnet for apim'
    destinationAddressPrefix: 'VirtualNetwork'

    destinationPortRange: '6390'

    direction: 'Inbound'
    priority: priorityOffset + 3
    protocol: '*'
    sourceAddressPrefix: 'AzureLoadBalancer'
    sourcePortRange: '*'
  }
}

resource AllowAPIManagement443Vnet 'Microsoft.Network/networkSecurityGroups/securityRules@2023-04-01' = if (apimSubnetNsg) {
  parent: nsg
  name: 'allow-traffic-manager-apim'
  properties: {
    access: 'Allow'
    description: 'Allow traffic from TrafficManager to Vnet'
    destinationAddressPrefix: 'VirtualNetwork'
    destinationPortRange: '443'

    direction: 'Inbound'
    priority: priorityOffset + 4
    protocol: 'TCP'
    sourceAddressPrefix: 'AzureTrafficManager'
    sourcePortRange: '*'
  }
}

//OUTBOUND

resource AllowAPIManagementStorage 'Microsoft.Network/networkSecurityGroups/securityRules@2023-04-01' = if (apimSubnetNsg) {
  parent: nsg
  name: 'allow-apim-storage'
  properties: {
    access: 'Allow'
    description: 'Allow traffic from apim to storage'
    destinationAddressPrefix: 'Storage'
    destinationPortRange: '443'

    direction: 'Outbound'
    priority: priorityOffset + 1
    protocol: 'TCP'
    sourceAddressPrefix: 'VirtualNetwork'
    sourcePortRange: '*'
  }
}

resource AllowAPIManagementSQL 'Microsoft.Network/networkSecurityGroups/securityRules@2023-04-01' = if (apimSubnetNsg) {
  parent: nsg
  name: 'allow-apim-sql'
  properties: {
    access: 'Allow'
    description: 'Allow traffic from apim to sql'
    destinationAddressPrefix: 'SQL'
    destinationPortRange: '1433'

    direction: 'Outbound'
    priority: priorityOffset + 2
    protocol: 'TCP'
    sourceAddressPrefix: 'VirtualNetwork'
    sourcePortRange: '*'
  }
}

resource AllowAPIManagementKeyvault 'Microsoft.Network/networkSecurityGroups/securityRules@2023-04-01' = if (apimSubnetNsg) {
  parent: nsg
  name: 'allow-apim-keyvault'
  properties: {
    access: 'Allow'
    description: 'Allow traffic from apim to AzureKeyVault'
    destinationAddressPrefix: 'AzureKeyVault'
    destinationPortRange: '443'

    direction: 'Outbound'
    priority: priorityOffset + 3
    protocol: 'TCP'
    sourceAddressPrefix: 'VirtualNetwork'
    sourcePortRange: '*'
  }
}
