
#setting up variable as per our environment
$MisubId = "6ee856b5-yy6d-4bc1-xxxx-byg5569842e1"
$instance = "packtsqlmi"
$resourceGroup = "Packt"

#Login to Azure Account
Connect-AzAccount

# Use your subscription ID in place of subscription-id below
Select-AzSubscription -SubscriptionId $MisubId

# Get the isntance information using resource group and isntance name.
$mi = Get-AzSqlInstance -ResourceGroupName $resourceGroup -Name $instance

# Set public endpoint access to true.
$mi = $mi | Set-AzSqlInstance -PublicDataEndpointEnabled $true -force


#Disable public endpoint access
$mi = $mi | Set-AzSqlInstance -PublicDataEndpointEnabled $false -force