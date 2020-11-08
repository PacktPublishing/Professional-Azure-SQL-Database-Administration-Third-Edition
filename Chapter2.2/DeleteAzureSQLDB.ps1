	## Code is reviewed and is in working condition
param(
	[string]
	$resourcegroupname,
	[string]
	$azuresqlservername,
	[string]
	$databasename
)
	Try
	{
		
		Login-AzAccount
        		$removesqldb = @{
                ResourceGroupName=$resourcegroupname
                ServerName=$azuresqlservername;
                DatabaseName= $databasename;
            }
            Remove-AzSqlDatabase;
  
		
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
	    $FailedItem = $_.Exception.ItemName
		Write-host $ErrorMessage $FailedItem -ForegroundColor Red
	}


