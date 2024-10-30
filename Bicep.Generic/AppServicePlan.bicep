param AppServicePlanName string
param AppServicePlanSku string
param Location string = resourceGroup().location

param SolutionName string
param CompanyTag string
param BusinessUnitTag string
param ContactTag string

resource AppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: AppServicePlanName
  location: Location
  tags: {
    Solution: SolutionName
    Company: CompanyTag
    'Business Unit': BusinessUnitTag
    Contact: ContactTag
  }
  sku: {
    name: AppServicePlanSku
  }
  properties: { }
}

output Id string = AppServicePlan.id
