CREATE DATABASE EcommerceDB;
GO

USE EcommerceDB;
GO

-- base tables
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE
);

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10,2),
    Stock INT
);

-- transactions
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT,
    UnitPrice DECIMAL(10,2)
);

-- tracking
CREATE TABLE AuditLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    LogMessage VARCHAR(255),
    LogDate DATETIME DEFAULT GETDATE()
);
GO

-- indexes
CREATE NONCLUSTERED INDEX IX_CustomerEmail ON Customers(Email);
GO

-- seed data
INSERT INTO Customers (FirstName, LastName, Email) VALUES
('Raj', 'Kumar', 'raj@email.com'),
('Priya', 'Sharma', 'priya@email.com');

INSERT INTO Products (ProductName, Price, Stock) VALUES
('Laptop', 850.00, 10),
('Wireless Mouse', 25.00, 50),
('Mechanical Keyboard', 60.00, 30);
GO

-- reporting view
CREATE VIEW vw_OrderReport AS
SELECT 
    o.OrderID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    p.ProductName,
    od.Quantity,
    (od.Quantity * od.UnitPrice) AS TotalCost,
    o.OrderDate
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;
GO

-- auto sync stock
CREATE TRIGGER trg_DeductInventory
ON OrderDetails
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.Stock = p.Stock - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

-- handle checkout logic safely
CREATE PROCEDURE sp_Checkout
    @CustID INT,
    @ProdID INT,
    @Qty INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CurrentPrice DECIMAL(10,2);
        DECLARE @NewOrderID INT;

        SELECT @CurrentPrice = Price FROM Products WHERE ProductID = @ProdID;

        INSERT INTO Orders (CustomerID) VALUES (@CustID);
        SET @NewOrderID = SCOPE_IDENTITY(); 

        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
        VALUES (@NewOrderID, @ProdID, @Qty, @CurrentPrice);

        INSERT INTO AuditLog (LogMessage) 
        VALUES ('Order ' + CAST(@NewOrderID AS VARCHAR) + ' completed for user ' + CAST(@CustID AS VARCHAR));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- test queries
EXEC sp_Checkout @CustID = 1, @ProdID = 1, @Qty = 1; 
EXEC sp_Checkout @CustID = 2, @ProdID = 2, @Qty = 2; 

SELECT * FROM vw_OrderReport;
SELECT ProductName, Stock FROM Products;
SELECT * FROM AuditLog;

SELECT FirstName, LastName 
FROM Customers 
WHERE CustomerID IN (SELECT DISTINCT CustomerID FROM Orders);