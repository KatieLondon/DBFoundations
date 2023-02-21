--*************************************************************************--
-- Title: Assignment06
-- Author: KLondon
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,KLondon,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KLondon')
	 Begin 
	  Alter Database [Assignment06DB_KLondon] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KLondon;
	 End
	Create Database Assignment06DB_KLondon;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KLondon;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
GO
-- Basic View of the Categories Table

CREATE VIEW vCategories -- Drop View vCategories
  WITH SCHEMABINDING
  AS
    SELECT CategoryID, CategoryName FROM dbo.Categories;
  GO

SELECT * FROM vCategories;

GO
-- Basic View of the Products Table
CREATE VIEW vProducts
WITH SCHEMABINDING
  AS
    SELECT ProductID, ProductName, CategoryID, UnitPrice FROM dbo.Products;
  GO

SELECT * FROM vProducts;

GO
-- Basic View of the Employees Table
CREATE VIEW vEmployees
WITH SCHEMABINDING
  AS
    SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID FROM dbo.Employees;
  GO

SELECT * FROM Employees;

GO
-- Basic View of the Products Table
CREATE VIEW vInventories
WITH SCHEMABINDING
  AS
    SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count FROM dbo.Inventories;
  GO
SELECT * FROM Inventories

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON Categories to PUBLIC;
GRANT Select ON Categories to PUBLIC;

DENY SELECT ON Employees to PUBLIC;
GRANT Select ON Employees to PUBLIC;

DENY SELECT ON Inventories to PUBLIC;
GRANT Select ON Inventories to PUBLIC;

DENY SELECT ON Products to PUBLIC;
GRANT Select ON Products to PUBLIC;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
GO
CREATE View  vProductsByCategories
AS
SELECT TOP 10000
    CategoryName, ProductName, UnitPrice
FROM vCategories INNER JOIN vProducts
ON vCategories.CategoryID = vProducts.CategoryID
ORDER BY CategoryName, ProductName;

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
GO
CREATE VIEW vInventoriesByProductsByDates
AS
SELECT TOP 10000
    ProductName, InventoryDate, Count
FROM vProducts INNER JOIN vInventories
ON vProducts.ProductID = vInventories.ProductID
ORDER BY ProductName, InventoryDate, Count;
GO
Select * From vInventoriesByProductsByDates;
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
GO
CREATE VIEW vInventoriesByEmployeesByDates
AS 
SELECT TOP 10000
	vD.InventoryDate,  
	vE.EmployeeFirstName + ' ' + vE.EmployeeLastName AS EmployeeName
FROM vEmployees as vE 
INNER JOIN (SELECT DISTINCT InventoryDate, EmployeeID 
	 FROM vInventories) AS vD 
 ON vE.EmployeeID = vD.EmployeeID
ORDER BY InventoryDate;
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
-- DROP View vTransactions
GO
CREATE VIEW vInventoriesByProductsByCategories
AS
SELECT TOP 10000
CategoryName, ProductName, InventoryDate, Count 
FROM Products AS P
 INNER JOIN Categories AS C
 ON P.CategoryID = C.CategoryID
 INNER JOIN Inventories AS I 
 ON P.ProductID = I.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, Count
GO 
Select * From vInventoriesByProductsByCategories;
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
-- DROP View vFullTransaction
GO
CREATE VIEW vInventoriesByProductsByEmployees
AS
SELECT TOP 10000
	CategoryName, 
	ProductName, 
	InventoryDate, 
	Count, 
	EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
FROM Categories AS C
 INNER JOIN Products AS P
 ON C.CategoryID = P.CategoryID
 INNER JOIN Inventories AS I
 ON P.ProductID = I.ProductID
 INNER JOIN Employees AS E
 ON I.EmployeeID = E.EmployeeID
ORDER BY InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
GO 
Select * From vInventoriesByProductsByEmployees
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
GO
CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
SELECT TOP 10000
	CategoryName, 
	ProductName, 
	InventoryDate, 
	Count, 
	EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
FROM Categories AS C
 INNER JOIN Products AS P
 ON C.CategoryID = P.CategoryID
 INNER JOIN Inventories AS I
 ON P.ProductID = I.ProductID
 INNER JOIN Employees AS E
 ON I.EmployeeID = E.EmployeeID
 WHERE P.ProductID IN (SELECT Products.ProductID
					FROM Products
					WHERE Products.ProductName = 'Chai' OR Products.ProductName = 'Chang')
ORDER BY InventoryDate, C.CategoryID, P.ProductID, EmployeeName;
GO

SELECT * FROM vInventoriesForChaiAndChangByEmployees

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
GO
CREATE VIEW vEmployeesByManager
AS
SELECT TOP 10000 
	M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
FROM Employees AS E 
INNER JOIN Employees AS M
ON E.ManagerID = M.EmployeeID
ORDER BY Manager, Employee;
GO

SELECT * FROM vEmployeesByManager

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
-- Drop View vInventoriesByProductsByCategoriesByEmployees
GO
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
SELECT NULL, CategoryID, CategoryName FROM vCategories
UNION ALL
SELECT ProductID, ProductName, CategoryID, UnitPrice FROM vProducts
GO


/*AS
SELECT
FROM vProducts as vP 
 OUTER JOIN vCategories as vC
 ON vP.Category ID= vC.CategoryID
 OUTER JOIN vInventories as vI
 ON vP.ProductID = vI.ProductID
 OUTER JOIN v.Employees as vE 
GO*/

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/