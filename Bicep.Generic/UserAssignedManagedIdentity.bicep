param Location string = resourceGroup().location
param ManagedIdentityName string
param SolutionName string
param CompanyTag string
param BusinessUnitTag string
param ContactTag string

resource UserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: ManagedIdentityName
  location: Location
  tags: {
    Solution: SolutionName
    Company: CompanyTag
    'Business Unit': BusinessUnitTag
    Contact: ContactTag
  }
}

output PrincipalId string = UserAssignedIdentity.properties.principalId
output ClientId string = UserAssignedIdentity.properties.clientId
output Id string = UserAssignedIdentity.id
