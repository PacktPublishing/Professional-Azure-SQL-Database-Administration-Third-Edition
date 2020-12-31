#setting up variable as per our environment
$MisubId = "6ee856b5-yy6d-4bc1-xxxx-byg5569842e1"
$instance = "packtsqlmi"
$resourceGroup = "Packt"
$database = "toystore"
$days =0

#Login to Azure Account
Connect-AzAccount
Select-AzSubscription -SubscriptionId $MisubId

# GET PITR backup retention for an individual deleted database
Get-AzSqlDeletedInstanceDatabaseBackup -ResourceGroupName $resourceGroup -InstanceName $instance -DatabaseName $database | Get-AzSqlInstanceDatabaseBackupShortTermRetentionPolicy


# SET new PITR backup retention on an individual deleted database
# Valid backup retention must be between 0 (no retention) and 35 days. Valid retention rate can only be lower than the period of the retention period when database was active, or remaining backup days of a deleted database
Get-AzSqlDeletedInstanceDatabaseBackup -ResourceGroupName $resourceGroup -InstanceName $instance -DatabaseName $database | Set-AzSqlInstanceDatabaseBackupShortTermRetentionPolicy -RetentionDays $days
