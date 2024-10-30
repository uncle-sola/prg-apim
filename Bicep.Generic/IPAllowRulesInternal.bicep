param AppServiceName string
param IPWhiteListAdditions array?

resource AppService 'Microsoft.Web/sites@2023-12-01' existing = {
  name: AppServiceName
}

var CidrAllowRules = [
  {
    name: 'CWH1'
    expression: '212.241.233.78/32'
  }
  {
    name: 'CWH2'
    expression: '212.241.134.60/32'
  }
  {
    name: 'VPN - DCA'
    expression: '213.86.220.156/32'
  }
  {
    name: 'VPN - DCB'
    expression: '213.86.220.195/32'
  }
  {
    name: 'LAV 1'
    expression: '213.86.220.155/32'
  }
  {
    name: 'DCA Network'
    expression: '80.169.4.130/32'
  }
  {
    name: 'DCB Network'
    expression: '80.169.4.138/32'
  }
]

var IpSecurityRestrictions = [for (rule,i) in concat(CidrAllowRules, IPWhiteListAdditions ?? []): {
  ipAddress: rule.?expression
  action: 'Allow'
  priority: 500 + i
  name: rule.?name
}]

var TagSecurityRestriction = [{
  ipAddress: 'AzureCloud'
  tag: 'ServiceTag'
  action: 'Allow'
  priority: 1000
  name: 'AzureCloudTag'
}]

resource SitesConfig 'Microsoft.Web/sites/config@2021-02-01' =  {
  name: 'web'
  parent: AppService
  properties: {
    scmIpSecurityRestrictionsUseMain: true
    publicNetworkAccess: 'Enabled'
    ipSecurityRestrictions: concat(IpSecurityRestrictions, TagSecurityRestriction)
  }
}

