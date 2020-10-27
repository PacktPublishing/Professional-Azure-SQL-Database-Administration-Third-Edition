cd "C:\Program Files\Microsoft Data Migration Assistant\"
powershell.exe -File .\SkuRecommendationDataCollectionScript.ps1 -ComputerName XENA -OutputFilePath "C:\Professional-Azure-SQL-Database-Administration-Third-Edition\Chapter02\DMA\Counter.csv" -CollectionTimeInSeconds 2400 -DbConnectionString "Server=XENA\SQL2016;Initial Catalog=master;Integrated Security=SSPI;"
@echo off
pause