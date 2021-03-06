﻿## Point-in-time restore on same instance.

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
		[string]$newdatabasename	
)

# Login to Azure subscription
Login-AzAccount
Select-AzSubscription -SubscriptionId $subscriptionId

# list the earliest restore point
# Ask user for the point in time the database is to be restored

While (1)
		{
            #Retrieve the distinct restore points from which a Database can be restored
			$restoredetails = Get-AzSqlInstanceDatabase -InstanceName $managedInstanceName -Name $databaseName -ResourceGroupName $resourcegroupname
			#get the earliest restore point
            $erd=$restoredetails.EarliestRestorePoint.ToString();
			#ask for the point in time the database is to be restored
            $restoretime = Read-Host "The earliest restore time is $erd.`n Enter a restore time between Earlist restore time and current time." 
			#convert the input to datetime date type
            $restoretime = $restoretime -as [DateTime]
			#if restore time isn't a valid data, prompt for a valid date
            if(!$restoretime)
			{
				Write-Host "Enter a valid date" -ForegroundColor Red
			}else
			{
                #end the while loop if restore date is a valid date
				break;
			}
		}

        #set the new database name
	    if([string]::IsNullOrEmpty($newdatabasename))
        { 
            $newdatabasename = $databaseName + (Get-Date).ToString("MMddyyyymm")
        }


		Write-Host "Restoring Database $databaseName as of $newdatabasename to the time $restoretime"
        
        #restore the database to point in time
	    $restore = Restore-AzSqlInstanceDatabase -FromPointInTimeBackup -ResourceGroupName $resourcegroupname -InstanceName $managedInstanceName -Name $databaseName -PointInTime $restoretime -TargetInstanceDatabaseName $newdatabasename


		if($rerror -ne $null)
		{
			Write-Host $rerror -ForegroundColor red;
		}
		if($restore -ne $null)
		{
			Write-Host "Database $newdatabasename restored Successfully" -ForegroundColor Green;
		}


##.\SQLMI_PITROnSameInstance.ps1 -resourcegroupname Packt -subscriptionId 6ee856b5-yy6d-4bc1-a901-byg5569842e1 -managedInstanceName packtsqlmi -databaseName toystore -newdatabasename toystorepitr