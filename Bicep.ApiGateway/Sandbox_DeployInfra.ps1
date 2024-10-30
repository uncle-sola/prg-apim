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
$subscriptionId = "f3b14109-a3de-4f54-9f58-46d891380a7e" 

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
$DeploymentParentName = "ApiGatewayInfraPoC" 
$BicepParentFilePath = ".\ApiGatewayInfra.bicep"
$ResourceGroupName = "rgInfra"

$LogAnalyticsName = "UKS-POC-LAI-ApiGateway"
$AppInsightsName = "UKS-POC-AIN-ApiGateway"
$StorageAccountName = "prgst001"
$ManagedIdentityStorageContributorName = "PRG-SA-Contributor"
$vaultName ="ApiGatewayKv"

$ExistingVnetName = 'apim-vnet'
$ExistingVnetRG = 'rgNet'
$ExistingVnetSubscription = 'f3b14109-a3de-4f54-9f58-46d891380a7e'
$subnet02Name  = 'UKS-POC-SUB0002-ApiGateway'

$Params = @(
   [PSCustomObject]@{ Name = "LogAnalyticsName"; Value = $LogAnalyticsName }
   [PSCustomObject]@{ Name = "AppInsightsName"; Value = $AppInsightsName }
   [PSCustomObject]@{ Name = "StorageAccountName"; Value = $StorageAccountName }
   [PSCustomObject]@{ Name = "ManagedIdentityStorageContributorName"; Value = $ManagedIdentityStorageContributorName }
   [PSCustomObject]@{ Name = "vaultName"; Value = $vaultName }
   [PSCustomObject]@{ Name = "ExistingVnetName"; Value = $ExistingVnetName }   
   [PSCustomObject]@{ Name = "ExistingVnetRG"; Value = $ExistingVnetRG }   
   [PSCustomObject]@{ Name = "ExistingVnetSubscription"; Value = $ExistingVnetSubscription }   
   [PSCustomObject]@{ Name = "subnet02Name"; Value = $subnet02Name }
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
