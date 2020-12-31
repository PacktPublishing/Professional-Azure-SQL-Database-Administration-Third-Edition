##Instance pool deployment script
##Setting up parameters

param(

        [Parameter(Mandatory=$true)]
		[string]$resourceGroup,
        [Parameter(Mandatory=$true)]
		[string]$subscription,
		[Parameter(Mandatory=$true)]
		[string]$instancePoolName,
		[Parameter(Mandatory=$true)]
		[string]$vnetName,
        [Parameter(Mandatory=$true)]
		[string]$subnetName,
        [Parameter(Mandatory=$true)]
		[string]$LicenseType,
        [Parameter(Mandatory=$true)]
		[string]$Edition,
        [Parameter(Mandatory=$true)]
        [string]$ComputeGeneration,
        [Parameter(Mandatory=$true)]
		[string]$Location

)

Write-Host "Login to Azure account" -ForegroundColor Green
##Login to Azure
#Set Azure subscription for deployment
Login-AzAccount
Select-AzSubscription -SubscriptionId $subscription

Write-Host "Get virtual network and subnet configuration" -ForegroundColor Green
###Get virtual network and subnet configuration
$virtualNetwork = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $virtualNetwork

Write-Host "Deploying instance pool " $instancePoolName -ForegroundColor Green
#Creating new instance pool with 8-vCore
$instancePool = New-AzSqlInstancePool -ResourceGroupName $resourceGroup -Name $instancePoolName -SubnetId $subnet.Id -LicenseType "LicenseIncluded" -VCore 8 -Edition "GeneralPurpose" -ComputeGeneration "Gen5" -Location "eastus"

##Sample for executing save powershell script
##.\SQLMI_InstancePoolDeployment.ps1 -resourceGroup Packt -subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -instancePoolName mi-toyfactory-pool -vnetName MyNewVNet -subnetName ManagedInstances -LicenseType LicenseIncluded -Edition GeneralPurpose -ComputeGeneration Gen5 -Location eastus