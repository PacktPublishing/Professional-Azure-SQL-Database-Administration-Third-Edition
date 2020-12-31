# Get the SQL Managed Instance for your subscription
$MisubId = "6ee856b5-yy6d-4bc1-xxxx-byg5569842e1"
$SQLinstanceName = "packtsqlmi"
$ResourceGroup = "Packt"
$InstancedbName = "toystore"
$TargetInstancedbName = "toystore_restore"

#Login to Azure Account
Connect-AzAccount
Select-AzSubscription -SubscriptionId $MisubId

$instance = Get-AzSqlInstance -Name $SQLinstanceName -ResourceGroupName $ResourceGroup

# create LTR policy with WeeklyRetention = 6 weeks. MonthlyRetention and YearlyRetention = 0 by default.
Set-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy -InstanceName $SQLinstanceName `
   -DatabaseName $InstancedbName -ResourceGroupName $ResourceGroup -WeeklyRetention P6W

# create LTR policy with WeeklyRetention = 6 weeks, YearlyRetention = 5 years and WeekOfYear = 16 (week of April 15). MonthlyRetention = 0 by default.
Set-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy -InstanceName $SQLinstanceName `
    -DatabaseName $InstancedbName -ResourceGroupName $ResourceGroup -WeeklyRetention P6W -YearlyRetention P5Y -WeekOfYear 16

<#View LTR Policies
# Gets the current version of LTR policy for a database#>
Get-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy -InstanceName $SQLinstanceName `
    -DatabaseName $InstancedbName -ResourceGroupName $ResourceGroup


#View LTR backups
# Get the list of LTR backups from the Azure region under the given managed instance
Get-AzSqlInstanceDatabaseLongTermRetentionBackup -Location $instance.Location -InstanceName $SQLinstanceName

# Get the LTR backups for a specific database from the Azure region under the given managed instance
Get-AzSqlInstanceDatabaseLongTermRetentionBackup -Location $instance.Location -InstanceName $SQLinstanceName -DatabaseName $InstancedbName

# Only list the latest LTR backup for each database
Get-AzSqlInstanceDatabaseLongTermRetentionBackup -Location $instance.Location -InstanceName $SQLinstanceName -OnlyLatestPerDatabase


#Delete LTR Backups
# remove the earliest backup
$ltrBackup = $ltrBackups[0]
Remove-AzSqlInstanceDatabaseLongTermRetentionBackup -ResourceId $ltrBackup.ResourceId

<##Restore from latest LTR backups#>

#Get latest LTR Backup
$ltrBackups = Get-AzSqlInstanceDatabaseLongTermRetentionBackup -Location $instance.Location -InstanceName $SQLinstanceName -DatabaseName $InstancedbName -OnlyLatestPerDatabase

#Initiate Restore
Restore-AzSqlInstanceDatabase -FromLongTermRetentionBackup -ResourceId $ltrBackup.ResourceId `
   -TargetInstanceName $SQLinstanceName -TargetResourceGroupName $ResourceGroup -TargetInstanceDatabaseName $TargetInstancedbName


#Remove LTR Policy
Set-AzSqlInstanceDatabaseBackupLongTermRetentionPolicy -InstanceName $SQLinstanceName `
   -DatabaseName $InstancedbName -ResourceGroupName $ResourceGroup -RemovePolicy
