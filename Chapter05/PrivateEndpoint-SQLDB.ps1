# Provision a private endpoint for Azure SQL Database and
# deny public access
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $privateendpointname,
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
    $azuresqlservername
)

$peconname = $privateendpointname + "_connection";

$azsqlserver = Get-AzSqlServer -ResourceGroupName $resourcegroup -ServerName $azuresqlservername


$pecon = New-AzPrivateLinkServiceConnection -Name $peconname `
  -PrivateLinkServiceId $azsqlserver.ResourceId `
  -GroupId "sqlServer" 
 
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourcegroup -Name $vnetname
 
$subnet = $vnet `
  | Select -ExpandProperty subnets `
  | Where-Object  {$_.Name -eq $subnetname}  
 
New-AzPrivateEndpoint -ResourceGroupName $resourcegroup `
  -Name $privateendpointname `
  -Location $vnet.Location `
  -Subnet  $subnet `
  -PrivateLinkServiceConnection $pecon

$dnszone = New-AzPrivateDnsZone -ResourceGroupName $resourcegroup `
  -Name "privatelink.database.windows.net" 
 
New-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $resourcegroup `
  -ZoneName "privatelink.database.windows.net"`
  -Name "vnetdnszonelink" `
  -VirtualNetworkId $vnet.Id  

$config = New-AzPrivateDnsZoneConfig -Name "privatelink.database.windows.net" -PrivateDnsZoneId $dnszone.ResourceId

New-AzPrivateDnsZoneGroup -ResourceGroupName $resourcegroup `
 -PrivateEndpointName $privateendpointname -name "dnszonegroup" -PrivateDnsZoneConfig $config
    

    
    

