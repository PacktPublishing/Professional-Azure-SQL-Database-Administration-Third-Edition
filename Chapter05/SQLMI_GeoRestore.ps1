## Geo-Restore for Azure SQL Managed Instance

param(

        [Parameter(Mandatory=$true)]
		[string]$resourcegroupname,
        [Parameter(Mandatory=$true)]
		[string]$subscriptionId,
		[Parameter(Mandatory=$true)]
		[string]$managedInstanceName,
		[Parameter(Mandatory=$true)]
		[string]$databaseName,
        [Parameter(Mandatory=$true)]
		[string]$targetResourceGroupName,
        [Parameter(Mandatory=$true)]
		[string]$targetManagedInstanceName,
        [Parameter(Mandatory=$true)]
		[string]$targetDatabaseName

)

# Login to Azure subscription
Login-AzAccount
Select-AzSubscription -SubscriptionId $subscriptionId


#Retrieve the distinct restore points from which a Database can be restored
$backup = Get-AzSqlInstanceDatabaseGeoBackup  -InstanceName $managedInstanceName -Name $databaseName -ResourceGroupName $resourcegroupname


        #set the new database name
	    if([string]::IsNullOrEmpty($targetDatabaseName))
        { 
            $targetDatabaseName = $databaseName + (Get-Date).ToString("MMddyyyymm")
        }


		Write-Host "Restoring Database $databaseName as $targetDatabaseName on $targetManagedInstanceName"
        
        #Initiate Geo restore
	    $restore = Restore-AzSqlInstanceDatabase -FromGeoBackup -ResourceGroupName $resourcegroupname -InstanceName $managedInstanceName -Name $databaseName -TargetInstanceDatabaseName $targetDatabaseName -TargetResourceGroupName $targetResourceGroupName -TargetInstanceName $targetManagedInstanceName


		if($rerror -ne $null)
		{
			Write-Host $rerror -ForegroundColor red;
		}
		if($restore -ne $null)
		{
			Write-Host "Database $targetDatabaseName restored Successfully on SQL Managed Instance $targetManagedInstanceName" -ForegroundColor Green;
		}


##.\SQLMI_GeoRestore.ps1 -resourcegroupname Packt -subscriptionId 6ee856b5-yy6d-4bc1-a901-byg5569842e1 -managedInstanceName packtsqlmi -databaseName toystore -targetDatabaseName toystorepitr -targetResourceGroupName Packt -targetManagedInstanceName packtsqlmi1