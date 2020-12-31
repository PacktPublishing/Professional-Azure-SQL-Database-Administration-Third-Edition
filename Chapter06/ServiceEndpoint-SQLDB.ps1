# Whitelist a virtual network using service endpoint

[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $vnetname,
    [Parameter()]
    [String]
    $resourcegroup,
    [Parameter()]
    [String]
    $subnetname,
    [Parameter()]
    [String]
    $sqlserver,
	[Parameter()]
    [String]
	$AzureProfileFilePath
)

# log the execution of the script
Start-Transcript -Path .\log\ProvisionAzureSQLDatabase.txt -Append
$scriptpath  = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$Codedir = Split-Path -Parent -Path $scriptpath

# Set AzureProfileFilePath relative to the script directory if it's not provided as parameter
if([string]::IsNullOrEmpty($AzureProfileFilePath))
{
    $AzureProfileFilePath="$Codedir\MyAzureProfile.json"
}

#Login to Azure Account
if((Test-Path -Path $AzureProfileFilePath))
{
	#If Azure profile file is available get the profile information from the file
    $azprofile = Import-AzContext -Path $AzureProfileFilePath
	#retrieve the subscription id from the profile.
    $SubscriptionID = $azprofile.Context.Subscription.SubscriptionId
}
else
{
    Write-Host "File Not Found $AzureProfileFilePath" -ForegroundColor Red
	
	# If the Azure Profile file isn't available, login using the dialog box.
    # Provide your Azure Credentials in the login dialog box
    $azprofile = Connect-AzAccount
    $SubscriptionID =  $azprofile.Context.Subscription.SubscriptionId
}

#Set the Azure Context
Set-AzContext -SubscriptionId $SubscriptionID | Out-Null


$azsqlserver = Get-AzSqlServer -ResourceGroupName $resourcegroup -ServerName $azuresqlservername

$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourcegroup -Name $vnetname
 
$subnet = $vnet `
  | Select -ExpandProperty subnets `
  | Where-Object  {$_.Name -eq $subnetname}  
 
$vnet = Set-AzVirtualNetworkSubnetConfig -Name $subnetname -ServiceEndpoint "Microsoft.Sql" -VirtualNetwork $vnet -AddressPrefix $subnet.AddressPrefix
$vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet

$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetname -VirtualNetwork $vnet
write-host $subnet.Id
New-AzSqlServerVirtualNetworkRule -ResourceGroupName $resourcegroup `
-ServerName $azuresqlservername `
-VirtualNetworkRuleName $vnetname `
-VirtualNetworkSubnetId $subnet.Id

