param publicIPAddress_name string
param location string = resourceGroup().location
param tags object
param publicIPAddress_name_domain string
param publicipfqdn string

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: publicIPAddress_name
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '2'
    '1'
    '3'
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: publicIPAddress_name_domain
      fqdn: publicipfqdn
    }
    ipTags: []
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
  }
}

output ipAddress string = publicIPAddress.properties.ipAddress
