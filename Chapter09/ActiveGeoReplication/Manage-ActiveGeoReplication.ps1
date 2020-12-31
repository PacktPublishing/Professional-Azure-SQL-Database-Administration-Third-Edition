## Code is reviewed and is in working condition

param
(
    [parameter(Mandatory=$true)]
	[String] $ResourceGroup,
    [parameter(Mandatory=$true)]
	[String] $PrimarySqlServer,
    [parameter(Mandatory=$true)]
	[String] $UserName,
    [parameter(Mandatory=$true)]
	[String] $Password,
    [parameter(Mandatory=$true)]
	[String] $SecondarySqlServer,
    [parameter(Mandatory=$true)]
	[String] $SecondaryServerLocation,
    [parameter(Mandatory=$false)]
	[bool] $Failover = $false,
    [parameter(Mandatory=$false)]
	[String] $DatabasesToReplicate,
    [parameter(Mandatory=$false)]
	# Add/Remove database to/from secondary server
    [String] $Operation = "none", 
    [parameter(Mandatory=$false)]
	[String] $AzureProfileFilePath
    

)


# log the execution of the script
Start-Transcript -Path ".\Log\Manage-ActiveGeoReplication.txt" -Append

# Set AzureProfileFilePath relative to the script directory if it's not provided as parameter

if([string]::IsNullOrEmpty($AzureProfileFilePath))
{
    $AzureProfileFilePath="..\..\MyAzureProfile.json"
}
    
#Login to Azure Account

if((Test-Path -Path $AzureProfileFilePath))
{
	#Select-AzProfile is obselete
	#$azprofile = Select-AzProfile -Path $AzureProfileFilePath
	$azprofile = Import-AzContext -Path $AzureProfileFilePath
    $SubscriptionID = $azprofile.Context.Subscription.SubscriptionId
}
else
{
    Write-Host "File Not Found $AzureProfileFilePath" -ForegroundColor Red

    # Provide your Azure Credentials in the login dialog box
    $azprofile = Login-AzAccount
    $SubscriptionID =  $azprofile.Context.Subscription.SubscriptionId
}

#Set the Azure Context
Set-AzContext -SubscriptionId $SubscriptionID | Out-Null

if($Operation -eq "Add")
{

    
    # Check if Azure SQL Server Exists
    # An error is returned and stored in notexists variable if resource group exists
    Get-AzSqlServer -ServerName $SecondarySqlServer -ResourceGroupName $ResourceGroup -ErrorVariable notexists -ErrorAction SilentlyContinue

    # provision the secondary server if it doesn't exists

    if($notexists)
        {
            Write-Host "Provisioning Azure SQL Server $SecondarySqlServer" -ForegroundColor Green
            $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $(ConvertTo-SecureString -String $Password -AsPlainText -Force)
            $_SecondarySqlServer = @{
             ResourceGroupName = $ResourceGroup;
             ServerName = $SecondarySqlServer;
             Location = $SecondaryServerLocation;
             SqlAdministratorCredentials = $credentials;
             ServerVersion = '12.0';
             }
             New-AzSqlServer @_SecondarySqlServer;
        }
        
}    
else
{
Write-Host $notexits -ForegroundColor Yellow
}


# Configure Active Geo-Replication for individual databases

if(![string]::IsNullOrEmpty($DatabasesToReplicate.Replace(',','')) -and $Operation -eq "Add")
{

    $dbname = $DatabasesToReplicate.Split(',');
    foreach($db in $dbname)
    {

        Write-Host "Replicating database $db to $SecondarySqlServer " -ForegroundColor Green
        #Get the database object for the given database name
        $database = Get-AzSqlDatabase -DatabaseName $db -ResourceGroupName $ResourceGroup -ServerName $PrimarySqlServer
        #pipe the database object to New-AzSqlDatabaseSecondary cmdlet
        $database | New-AzSqlDatabaseSecondary -PartnerResourceGroupName $ResourceGroup -PartnerServerName $SecondarySqlServer -AllowConnections "No"
    }
}


if($Operation -eq "Remove")
{
    $dbname = $DatabasesToReplicate.Split(',');
    foreach($db in $dbname)
    {

        Write-Host "Removing replication for database $db " -ForegroundColor Green
        $database = Get-AzSqlDatabase -DatabaseName $db -ResourceGroupName $ResourceGroup -ServerName $PrimarySqlServer
        $database | Remove-AzSqlDatabaseSecondary -PartnerResourceGroupName $ResourceGroup -ServerName $PrimarySqlServer -PartnerServerName $SecondarySqlServer
    }
}


# failover individual databases from primary to secondary
if($Failover -eq $true)
{

$dbname = $DatabasesToReplicate.Split(',');
foreach($db in $dbname)
    {

        Write-Host "Failover $db to $SecondarySqlServer..." -ForegroundColor Green
        $database = Get-AzSqlDatabase -DatabaseName $db -ResourceGroupName $ResourceGroup -ServerName $SecondarySqlServer
        $database | Set-AzSqlDatabaseSecondary -PartnerResourceGroupName $ResourceGroup -Failover

    }

}