targetScope = 'resourceGroup'
param AppInsightsName string
param LogAnalyticsId string
param DataCap int = 1
param RetentionInDays int = 30
param Location string 
param SolutionName string
param CompanyTag string
param BusinessUnitTag string
param ContactTag string

resource AppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: AppInsightsName
  location: Location
  tags: {
    Solution: SolutionName
    Company: CompanyTag
    'Business Unit': BusinessUnitTag
    Contact: ContactTag
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableLocalAuth: false
    Flow_Type: 'Bluefield'
    HockeyAppId: 'string'
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    Request_Source: 'rest'
    RetentionInDays: RetentionInDays
    SamplingPercentage: null
    WorkspaceResourceId: LogAnalyticsId
  }
}

resource PricingPlan 'microsoft.insights/components/pricingPlans@2017-10-01' = {
  name: 'current'
  parent: AppInsights
  properties: {
    cap: DataCap
    planType: 'Basic'
    stopSendNotificationWhenHitCap: true
    warningThreshold: 85
  }
}
