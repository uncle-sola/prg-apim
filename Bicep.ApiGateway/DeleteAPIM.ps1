$SubscriptionId = '3f88752d-7039-4e85-b9b9-22dd7b8adfb6'
$Region = 'uksouth'
$APIMInstanceName = 'ConnellsPOCAPIM'

Connect-AzAccount -Subscription $SubscriptionId

$accessToken = Get-AzAccessToken

$request = @{
    Method = 'DELETE'
    Uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/providers/Microsoft.ApiManagement/locations/$($Region)/deletedservices/$($APIMInstanceName)?api-version=2021-08-01"
    Headers = @{
        Authorization = "Bearer $($accessToken.Token)"
    }
}

Invoke-RestMethod @request