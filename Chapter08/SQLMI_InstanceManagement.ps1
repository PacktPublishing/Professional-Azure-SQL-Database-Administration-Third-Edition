##Deploying new SQL Managed Instance in pool.
##Get the instance pool properties.
$instancePool = Get-AzSqlInstancePool -ResourceGroupName Packt -Name mi-toyfactory-pool

#Using measure-command cmdlet to calculate time for new instance deployment in pool.
Measure-Command {$toystoreInstance = $instancePool | New-AzSqlInstance -Name mi-toystore-1 -AdministratorCredential (Get-Credential) -StorageSizeInGB 32 -VCore 2}

#Scaling SQL Managed Instance resources
Measure-Command {$toystoreInstance | Set-AzSqlInstance -VCore 8 -StorageSizeInGB 512 -InstancePoolName "mi-toyfactory-pool"}

<#
#Clean resources
#Delete pooled instance
Remove-AzSqlInstance -Name "mi-toystore-1" -ResourceGroupName "Packt"

#Delete Instance pool - Wait for few minutes after instance deletion
Remove-AzSqlInstancePool -ResourceGroup packt -Name mi-toyfactory-pool

#>