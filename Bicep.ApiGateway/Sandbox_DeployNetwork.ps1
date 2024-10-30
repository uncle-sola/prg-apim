function ParamBuilder
{
   param([Object]$ParamArg)
   $Arg = [PSCustomObject]::new()
   foreach ($Param in $ParamArg)
   {
      if ($Param.Value.Length -gt 0)
      {
         Write-Host Adding $Param.Name to parameter list with value $Param.Value
         $Arg | Add-Member NoteProperty -Name $Param.Name -Value ([PSCustomObject] @{ value = $Param.Value })
      } 
   }
   return ($Arg | ConvertTo-Json -Compress).Replace('"', '\"')
}

$azureApplicationId = "a3afbd46-9b29-4cd1-b7fb-756391e24922"                                             #$OctopusParameters["AzureAccount.Client"]
$azureTenantId = "893c6ab5-5aae-4706-be15-dc729e4f10e8"                                                  #$OctopusParameters["AzureAccount.TenantId"]
$azurePassword = ConvertTo-SecureString "" -AsPlainText -Force   #$OctopusParameters["AzureAccount.Password"]
$subscriptionId = "f3b14109-a3de-4f54-9f58-46d891380a7e"                                                 #$OctopusParameters["DunnoWhereWe'reGettin.ThisFromYet"]

############################
#### Authentication
############################
Write-Host AppId: $azureApplicationId
Write-Host Tenant: $azureTenantId
Write-Host Subscr: $subscriptionId
Write-Host Password: $azurePassword
   
$AzCred = New-Object System.Management.Automation.PSCredential($azureApplicationId , $azurePassword)
$AzLogin = az login --service-principal -u $AzCred.UserName -p $AzCred.GetNetworkCredential().Password --tenant $azureTenantId | ConvertFrom-Json
az account set --subscription $subscriptionId 
$acc = az account show | ConvertFrom-Json
Write-Host "Subscription scoped to"  $acc.name "-" $acc.id

####################
# Parent
####################
$DeploymentParentName = "ApiGatewayNetworkPoC" 
$BicepParentFilePath = ".\ApiGatewayNetwork.bicep"
$ResourceGroupName = "rgNet"

$ExistingVnetName = 'apim-vnet'
$ExistingVnetRG = 'rgNet'
$ExistingVnetSubscription = 'f3b14109-a3de-4f54-9f58-46d891380a7e'
$subnet01Range  = '10.10.4.0/28'
$subnet02Range  = '10.10.4.16/28'
$subnet01Name  = 'UKS-POC-SUB0001-ApiGateway'
$subnet02Name  = 'UKS-POC-SUB0002-ApiGateway'
$routeTableName  = 'UKS-POC-RT0001-ApiGateway'
$virtualApplianceIp  = '10.10.3.36'
$nsg1Name = 'UKS-POC-NSG0001-ApiGateway'
$nsg2Name = 'UKS-POC-NSG0002-ApiGateway'
$apimPublicIp = 'PRGAPIMPublicIP'

$Params = @(
   [PSCustomObject]@{ Name = "ExistingVnetName"; Value = $ExistingVnetName }   
   [PSCustomObject]@{ Name = "ExistingVnetRG"; Value = $ExistingVnetRG }   
   [PSCustomObject]@{ Name = "ExistingVnetSubscription"; Value = $ExistingVnetSubscription }   
   [PSCustomObject]@{ Name = "subnet01Range"; Value = $subnet01Range }
   [PSCustomObject]@{ Name = "subnet02Range"; Value = $subnet02Range }
   [PSCustomObject]@{ Name = "subnet01Name"; Value = $subnet01Name }
   [PSCustomObject]@{ Name = "subnet02Name"; Value = $subnet02Name }
   [PSCustomObject]@{ Name = "routeTableName"; Value = $routeTableName }
   [PSCustomObject]@{ Name = "virtualApplianceIp"; Value = $virtualApplianceIp }
   [PSCustomObject]@{ Name = "nsg1Name"; Value = $nsg1Name }
   [PSCustomObject]@{ Name = "nsg2Name"; Value = $nsg2Name }
   [PSCustomObject]@{ Name = "apimPublicIp"; Value = $apimPublicIp }
)
$ParamString = ParamBuilder -ParamArg $Params

Write-Host Deploying $DeploymentParentName

az deployment group create `
   --resource-group $ResourceGroupName `
   --template-file $BicepParentFilePath `
   --name $DeploymentParentName `
   --parameters $ParamString `
   --debug

Write-Host Deployment complete
