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
$DeploymentParentName = "ApiGatewayVnetPoC" 
$BicepParentFilePath = ".\ApiGatewayVnet.bicep"
$ResourceGroupName = "rgNet"


$VnetName ='apim-vnet'
$addressPrefix = '10.10.4.0/24'

$Params = @(
   [PSCustomObject]@{ Name = "VnetName"; Value = $VnetName }
   [PSCustomObject]@{ Name = "addressPrefix"; Value = $addressPrefix }
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
