# Set the environment variables
$subId = "0000000-xxxx-000000-xxxx-000xxx00"
$instanceName = "packtsqlmi"
$resourceGroup = "packt"
$sourceDbName = "toystore"
$targetDbname = 'toystore_restore'

# Login to Azure account and select subscription
Connect-AzAccount
Select-AzSubscription -SubscriptionId $subId

# Get the isntance details
$instance = Get-AzSqlInstance -Name $instanceName -ResourceGroupName $resourceGroup


# get the latest LTR backup for a specific database from the Azure region under the given managed instance
$ltrBackup = Get-AzSqlInstanceDatabaseLongTermRetentionBackup -Location $instance.Location -InstanceName $instanceName -DatabaseName $sourceDbName -OnlyLatestPerDatabase


# restore a the LTR backup
Restore-AzSqlInstanceDatabase -FromLongTermRetentionBackup -ResourceId $ltrBackup.ResourceId -TargetInstanceName $instanceName -TargetResourceGroupName $resourceGroup -TargetInstanceDatabaseName $targetDbname

<# ouput

PS /home> Restore-AzSqlInstanceDatabase -FromLongTermRetentionBackup -ResourceId $ltrBackup.ResourceId -TargetInstanceName $instanceName -TargetResourceGroupName $resourceGroup -TargetInstanceDatabaseName $targetDbname

Location                          : eastus
Tags                              :
Collation                         : Latin1_General_100_CI_AS_KS_WS
Status                            : Online
RestorePointInTime                :
DefaultSecondaryLocation          : westus
CatalogCollation                  :
CreateMode                        :
StorageContainerUri               :
StorageContainerSasToken          :
SourceDatabaseId                  :
FailoverGroupId                   :
RecoverableDatabaseId             :
RestorableDroppedDatabaseId       :
LongTermRetentionBackupResourceId :
AutoCompleteRestore               :
LastBackupName                    :
ResourceGroupName                 : packt
ManagedInstanceName               : packtsqlmi
Name                              : toystore_restore
CreationDate                      : 11/20/2020 6:39:32 PM
EarliestRestorePoint              :
Id                                : /subscriptions/0000000-xxxx-000000-xxxx-000xxx00/resourceGroups/packt/providers/Microsoft.Sql/managedInstances/packtsqlmi/databases/toystore_restore


PS /home>

#>