cd "C:\Program Files\Microsoft Data Migration Assistant"
.\DmaCmd.exe /Action=SkuRecommendation /SkuRecommendationInputDataFilePath="C:\Professional-Azure-SQL-Database-Administration-Third-Edition\Chapter02\DMA\Counter.csv" /SkuRecommendationOutputResultsFilePath="C:\Professional-Azure-SQL-Database-Administration-Third-Edition\Chapter02\DMA\SKURecommedation.html" /SkuRecommendationPreventPriceRefresh=true /SkuRecommendationTsvOutputResultsFilePath=C:\Professional-Azure-SQL-Database-Administration-Third-Edition\Chapter02\DMA\SKURecommedation.tsv" 
@echo off
pause