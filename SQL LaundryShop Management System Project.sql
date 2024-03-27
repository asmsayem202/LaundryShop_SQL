/*   Name- A. S. M. SAYEM     */
/*   ID- 1274108              */
/*   Batch- CS/DITC-A/55/01   */



USE MASTER
GO
--DROP LOGIN  [Owner]
GO
Drop database if exists LaundryShop
go

Create Database LaundryShop;
go



Create LOGIN [Owner] WITH PASSWORD=N'123456', DEFAULT_DATABASE=LaundryShop
go


ALTER SERVER ROLE [dbcreator] ADD MEMBER [Owner]
go

Use LaundryShop;
go

CREATE USER [Operator] FOR LOGIN [Owner] WITH DEFAULT_SCHEMA = [dbo]
GO

ALTER ROLE [db_owner] ADD MEMBER [Operator]
GO

grant select, insert , update, delete, execute
on schema:: dbo
to [Operator]
GO


CREATE TABLE Customers (
CustomerID INT PRIMARY KEY,
Name VARCHAR(100),
Phone VARCHAR(15),
Address VARCHAR(100)
);


CREATE TABLE Orders (
OrderID INT PRIMARY KEY,
CustomerID INT,
OrderDate DATE,
TotalAmount DECIMAL(10,2),
FOREIGN KEY (CustomerID) REFERENCES
Customers(CustomerID)
);



CREATE TABLE Items (
ItemID INT PRIMARY KEY,
ItemName VARCHAR(100),
Price DECIMAL(10,2)
);


CREATE TABLE OrderItems (
OrderID INT,
ItemID INT,
Quantity INT,
PRIMARY KEY (OrderID, ItemID),
FOREIGN KEY (OrderID) REFERENCES
Orders(OrderID),
FOREIGN KEY (ItemID) REFERENCES
Items(ItemID)
);


CREATE TABLE Employees (
EmployeeID INT PRIMARY KEY,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Position VARCHAR(50),
Salary DECIMAL(10,2)
);


CREATE TABLE Transactions (
TransactionID INT PRIMARY KEY,
OrderID INT,
EmployeeID INT,
TransactionDate DATETIME,
FOREIGN KEY (OrderID) REFERENCES
Orders(OrderID),
FOREIGN KEY (EmployeeID) REFERENCES
Employees(EmployeeID)
);

go

INSERT INTO Customers (CustomerID, Name, Phone, Address)
VALUES 
(1,'Abdur Rahim', '01865987456', 'Ctg'),
(2,'Nayem Sharif', '01356987454', 'Dha'),
(3,'Jamir Uddin', '01965896325', 'Ctg'),
(4,'Shorab Chy', '01965896327', 'Raj');


INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES 
(1, 1,'2023-06-01', 50.00),
(2, 2,'2023-06-02', 75.00),
(3, 3,'2023-06-03', 60.00),
(4, 4,'2023-06-06', 80.00);


INSERT INTO Items (ItemID, ItemName, Price)
VALUES 
(1, 'Shirt', 10.00),
(2,'Pants', 15.00),
(3,'Panjabi', 25.00),
(4,'Kamiz', 25.00),
(5,'Salwar', 15.00);


INSERT INTO OrderItems (OrderID, ItemID, Quantity)
VALUES 
(1, 1, 2),
(1, 2, 1),
(2, 3, 5);


INSERT INTO Employees (EmployeeID, FirstName, LastName, Position, Salary)
VALUES (1,'Abul','Kashem','Cashier', 20000.00),
(2,'Iqbal','Hossain','Laundry Staff', 18000.00),
(3,'Jamal','Uddin','Laundry Staff', 15000.00);


INSERT INTO Transactions (TransactionID, OrderID, EmployeeID, TransactionDate)
VALUES (1, 1, 1, '2023-06-01 10:30:00'),
(2, 2, 2, '2023-06-02 11:00:00');

go


CREATE PROCEDURE GetOrderDetails
@OrderID INT
AS
BEGIN
SELECT o.OrderID, c.Name AS CustomerName,
i.ItemName, oi.Quantity, i.Price, o.TotalAmount
FROM Orders as o JOIN Customers as c 
ON o.CustomerID = c.CustomerID 
JOIN OrderItems as oi
On o.OrderID= oi.OrderID
JOIN Items as i 
On oi.ItemID=i.ItemID
Where o.OrderID=@OrderID;
END
go


CREATE FUNCTION GetOrderDetailsFunction
(@OrderID INT)
RETURNS TABLE
AS
RETURN
(SELECT o.OrderID, c.Name AS CustomerName,
i.ItemName, oi.Quantity, i.Price, o.TotalAmount
FROM Orders o
INNER JOIN Customers c ON o.CustomerID =
c.CustomerID
INNER JOIN OrderItems oi ON o.OrderID =
oi.OrderID
INNER JOIN Items i ON oi.ItemID = i.ItemID
WHERE o.OrderID = @OrderID
);

go

create view VwCustomers
as
select * from Customers
go

CREATE VIEW CustomerOrders AS
SELECT o.OrderID, c.Name,
i.ItemName, oi.Quantity
FROM Orders o
JOIN Customers c ON o.CustomerID =
c.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Items i ON oi.ItemID = i.ItemID;

go
create proc Sp_insert_Customers
@ID int,
@Name varchar(50),
@Phone varchar(20),
@address varchar(200)

with Recompile
as

INSERT INTO Customers (CustomerID, Name, Phone, Address)
VALUES 
(@ID, @Name, @Phone, @address)
go


create FUNCTION FnRetriveCutomerName
(@Id int)
RETURNS varchar(250)
AS
BEGIN

RETURN (Select Name from Customers 
Where CustomerID=@Id)

END
go

Create trigger TrCustomer
on Customers
Instead of insert
as
begin

select count(*) from inserted
if (@@ROWCOUNT>1)
throw 500001,'Multiple records can not be inserted once', 2;

insert into Customers (CustomerID, Name, Phone, Address)
select CustomerID, Name, Phone, Address from inserted
end