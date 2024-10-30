param AppServiceName string
param IPWhiteListAdditions array?

resource AppService 'Microsoft.Web/sites@2023-12-01' existing = {
  name: AppServiceName
}

module IpWhitelistGeneric 'br:connellsgroupbicepregistry.azurecr.io/bicep/modules/generic/ipwhitelistinternalgeneric:1.0.10' = {
  name: 'IpWhiteListGeneric'
  params: {
    IPWhiteListAdditions: IPWhiteListAdditions
  }

}

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
    ipSecurityRestrictions: concat(IpWhitelistGeneric.outputs.WebAppRuleList, TagSecurityRestriction)
  }
}

