<#
If you are using Pay-as-you-go subscription, do check the Azure SQL Managed Instance
#>

param(
[string]$ResourceGroup="Packt-1",
[string]$Location="WestUS",
[string]$vNet="PackvNet-$(Get-Random)",
[string]$misubnet="PackSubnet-$(Get-Random)",
[string]$miname="Packt-$(Get-Random)",
[string]$miadmin="miadmin",
[string]$miadminpassword="CreateYourAdminPassword1",
[string]$miedition="General Purpose",
[string]$mivcores=4,
[string]$mistorage=32,
[string]$migeneration = "Gen5",
[string]$milicense="LicenseIncluded",
[string]$subscriptionid="6ee856b5-yy6d-4bc1-a901-byg5569842e1"
)

# Powershell moduel for subnet delegation

$AznetworkModels = "Microsoft.Azure.Commands.Network.Models"
$Azcollections = "System.Collections.Generic"


# login to azure

$Account = Connect-AzAccount

if([string]::IsNullOrEmpty($subscriptionid))
{
   $subscriptionid=$Account.Context.Subscription.Id
}

Set-AzContext $subscriptionid

# Check if resource group exists
# An error is returned and stored in notexists variable if resource group exists
Get-AzResourceGroup -Name $ResourceGroup -Location $location -ErrorVariable notexists -ErrorAction SilentlyContinue

#Provision Azure Resource Group
if(![string]::IsNullOrEmpty($notexists))
{

Write-Host "Provisioning Azure Resource Group $ResourceGroup" -ForegroundColor Green
$_ResourceGroup = @{
  Name = $ResourceGroup;
  Location = $Location;
  }
New-AzResourceGroup @_ResourceGroup;
}
else
{

Write-Host $notexists -ForegroundColor Yellow
}

# Configure virtual network, subnets, network security group, and routing table

Write-Host "Provisioning Azure Virtual Network $vNet" -ForegroundColor Green
$obvnet = New-AzVirtualNetwork -Name $vNet -ResourceGroupName $ResourceGroup -Location $Location -AddressPrefix "10.0.0.0/16"

Write-Host "Provisioning Managed instance subnet $misubnet" -ForegroundColor Green

$obmisubnet = Add-AzVirtualNetworkSubnetConfig -Name $misubnet -VirtualNetwork $obvnet -AddressPrefix "10.0.0.0/24"

$_nsg = "mi-nsg"
$_rt = "mi-rt"

Write-Host "Provisioning Network Security Group $_nsg" -ForegroundColor Green
$nsg = New-AzNetworkSecurityGroup -Name $_nsg -ResourceGroupName $ResourceGroup -Location $Location -Force

<#
Routing table is required for a managed instance to connect with Azure Management Service. 
#>
Write-Host "Provisioning Routing table $_rt" -ForegroundColor Green
$routetable = New-AzRouteTable -Name $_rt -ResourceGroupName $ResourceGroup -Location $Location -Force

#Assign network security group to managed instance subnet
Set-AzVirtualNetworkSubnetConfig `
-VirtualNetwork $obvnet -Name $misubnet `
-AddressPrefix "10.0.0.0/24" -NetworkSecurityGroup $nsg `
-RouteTable $routetable | Set-AzVirtualNetwork

$obvnet = Get-AzVirtualNetwork -Name $vNet -ResourceGroupName $ResourceGroup
$obmisubnet= $obvnet.Subnets[0]

# Create a delegation
Write-Host "Create a subnet delegation" -ForegroundColor Green
$obmisubnet.Delegations = New-Object "$Azcollections.List``1[$AznetworkModels.PSDelegation]"
$delegationName = "dlManagedInstance" + (Get-Random -Maximum 1000)
$delegation = New-AzDelegation -Name $delegationName -ServiceName "Microsoft.Sql/managedInstances"
$obmisubnet.Delegations.Add($delegation)

Set-AzVirtualNetwork -VirtualNetwork $obvnet
$misubnetid = $obmisubnet.Id

$allowParameters = @{
    Access = 'Allow'
    Protocol = 'Tcp'
    Direction= 'Inbound'
    SourcePortRange = '*'
    SourceAddressPrefix = 'VirtualNetwork'
    DestinationAddressPrefix = '*'
}
$denyInParameters = @{
    Access = 'Deny'
    Protocol = '*'
    Direction = 'Inbound'
    SourcePortRange = '*'
    SourceAddressPrefix = '*'
    DestinationPortRange = '*'
    DestinationAddressPrefix = '*'
}
$denyOutParameters = @{
    Access = 'Deny'
    Protocol = '*'
    Direction = 'Outbound'
    SourcePortRange = '*'
    SourceAddressPrefix = '*'
    DestinationPortRange = '*'
    DestinationAddressPrefix = '*'
}

#Configuring network rules in network security group

Write-Host "Configure network rules in network security group" -ForegroundColor Green

Get-AzNetworkSecurityGroup `
        -ResourceGroupName $ResourceGroup `
        -Name $_nsg |
    Add-AzNetworkSecurityRuleConfig `
        @allowParameters `
        -Priority 1000 `
        -Name "allow_tds_inbound" `
        -DestinationPortRange 1433 |
    Add-AzNetworkSecurityRuleConfig `
        @allowParameters `
        -Priority 1100 `
        -Name "allow_redirect_inbound" `
        -DestinationPortRange 11000-11999 |
    Add-AzNetworkSecurityRuleConfig `
        @denyInParameters `
        -Priority 4096 `
        -Name "deny_all_inbound" |
    Add-AzNetworkSecurityRuleConfig `
        @denyOutParameters `
        -Priority 4096 `
        -Name "deny_all_outbound" |
    Set-AzNetworkSecurityGroup          




# Creating credential
Write-Host "Creating credential" -ForegroundColor Green
  $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $miadmin, (ConvertTo-SecureString -String $miadminpassword -AsPlainText -Force)

# Provision Azure SQL Managed Instance
Write-Host "Provisioning Azure SQL Managed Instance $miname" -ForegroundColor Green
New-AzSqlInstance -Name $miname -ResourceGroupName $ResourceGroup -Location $Location -SubnetId $misubnetid `
                      -AdministratorCredential $creds `
                      -StorageSizeInGB $mistorage -VCore $mivcores -Edition $miedition `
                      -ComputeGeneration $migeneration -LicenseType $milicense


<#
Clean-Up : Remove Azure SQL Managed Instance
Remove-AzSqlInstance -Name $miadmin -ResourceGroupName $ResourceGroup -Force

#>
