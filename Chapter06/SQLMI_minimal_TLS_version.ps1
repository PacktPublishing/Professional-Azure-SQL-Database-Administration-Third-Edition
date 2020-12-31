
#setting up variable as per our environment
$MisubId = "6ee856b5-yy6d-4bc1-xxxx-byg5569842e1"
$InstanceName = "packtsqlmi"
$ResourceGroup = "Packt"

#Login to Azure Account
Connect-AzAccount

# Use your subscription ID in place of subscription-id below
Select-AzSubscription -SubscriptionId $MisubId

#Get the Minimal TLS Version property
(Get-AzSqlInstance -Name $InstanceName -ResourceGroupName $ResourceGroup).MinimalTlsVersion

# Update Minimal TLS Version Property
Set-AzSqlInstance -Name $InstanceName -ResourceGroupName $ResourceGroup -MinimalTlsVersion "1.1"