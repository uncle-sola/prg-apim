//// Parameters ////
@description('Specifies the principal id that is assigned a role')
param PrincipalId string

@description('Specifies the role using its definition id, that is granted to the principal id')
param RoleDefinitionId string 

//// Resources ////
@description('Creates a new role assignment')
resource RoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, PrincipalId, RoleDefinitionId)
  properties: {
    principalId: PrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', RoleDefinitionId)
  }
}

//// Outputs ////
@description('Outputs the role assignment name')
output RoleAssignmentName string = RoleAssignment.name

@description('Outputs the role assignment id')
output RoleAssignmentId string = RoleAssignment.id
