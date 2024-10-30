param AppName string
param CurrentAppSettings object 
param AppSettings object

resource App 'Microsoft.Web/sites@2022-03-01' existing = {
  name: AppName
}

resource siteconfig 'Microsoft.Web/sites/config@2020-12-01' = {
  parent: App
  name: 'appsettings'
  properties: union(CurrentAppSettings, AppSettings)
}
