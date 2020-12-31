#setting up variable as per your environment
$subscription = "6ff855b5-xxxx-4bc2-xxxx-xxxxxxxxx"
$managedInstance = "packtsqlmi"
$resourceGroup = "Packt"


#Select the managed instance subscription
Select-AzSubscription -SubscriptionId $subscription

#Updating license type, storage size and moving instance to business critical server tier.
Set-AzSqlInstance -Name $manangedInstance -ResourceGroupName $resourceGroup -LicenseType LicenseIncluded -StorageSizeInGB 1024 -VCore 16 -Edition BusinessCritical
