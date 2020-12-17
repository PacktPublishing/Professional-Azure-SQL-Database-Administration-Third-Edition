CREATE TABLE orders (
	id int IDENTITY, 
	productid INT,
	quantity INT,
	unitprice MONEY,
	orderdate DATETIME DEFAULT getdate()
)