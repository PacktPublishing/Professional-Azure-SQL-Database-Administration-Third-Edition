CREATE OR ALTER PROCEDURE InsertOrders
AS
SET NOCOUNT ON
DECLARE @i INT = 1
WHILE(@i<=10000)
BEGIN
INSERT INTO orders(productid,quantity,unitprice) VALUES(@i*2,@i,@i*2.3)
SET @i=@i+1
END