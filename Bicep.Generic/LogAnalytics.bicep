targetScope = 'resourceGroup'
param LogAnalyticsName string
param Location string
param DailyQuotaGB int = 1
param SolutionName string 
param CompanyTag string
param BusinessUnitTag string
param ContactTag string

resource LogAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: LogAnalyticsName
  location: Location
  tags: {
    Solution: SolutionName
    Company: CompanyTag
    'Business Unit': BusinessUnitTag
    Contact: ContactTag
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    features: {
      enableDataExport: false
      enableLogAccessUsingOnlyResourcePermissions: true
      immediatePurgeDataOn30Days: true
    }
    forceCmkForQuery: false
    publicNetworkAccessForIngestion: 'Enabled'
    sku: {
      name: 'pergb2018'
    }
    workspaceCapping: {
      dailyQuotaGb: DailyQuotaGB
    }
  }
}

output Id string = LogAnalytics.id
