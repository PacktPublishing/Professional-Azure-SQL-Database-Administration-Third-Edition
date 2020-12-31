#setting up variable as per your environment
$subscription = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx"
$resourceGroup = "SQLServer"
$serverName = "toyfactory1"
$databaseName = "toystore1"
$edition = "Hyperscale"
$sku = "HS_Gen5_2"
$replicaCount =1

#Select the Azure SQL Database subscription
Select-AzSubscription -SubscriptionId $subscription

#Updating existing Azure SQL Database to Hyperscale service tier.
Set-AzSqlDatabase -ResourceGroupName $resourceGroup -DatabaseName $databaseName -ServerName $serverName -Edition $edition -RequestedServiceObjectiveName $sku -ReadReplicaCount $replicaCount
