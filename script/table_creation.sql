USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'pizza_sale_analysis')
BEGIN
ALTER DATABASE pizza_sale_analysis  SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE  pizza_sale_analysis;
END;
GO

CREATE DATABASE pizza_sale_analysis;
GO
USE pizza_sale_analysis;


-- TABLE CREATION --

IF OBJECT_ID ('pizza', 'U') IS NOT NULL
DROP TABLE pizza;
GO

CREATE TABLE pizza (
				pizza_id VARCHAR (50),
				pizza_type_id VARCHAR (20),
				size VARCHAR (5),
				price DECIMAL (10,2)
				);
GO

IF OBJECT_ID ('order_detail', 'U') IS NOT NULL
DROP TABLE order_detail;
GO

CREATE TABLE order_detail (
				order_details_id INT,
				order_id INT,
				pizza_id VARCHAR (50),
				quantity INT
				);
GO

IF OBJECT_ID ('orders', 'U') IS NOT NULL
DROP TABLE orders;
GO

CREATE TABLE orders (
				order_id INT,
				date DATE,
				time TIME
				);
GO

IF OBJECT_ID ('type', 'U') IS NOT NULL
DROP TABLE type;
GO

CREATE TABLE type (
				pizza_type_id VARCHAR (50),
				name VARCHAR (100),
				category VARCHAR (MAX),
				ingredients VARCHAR (MAX)
				);
GO

-- LOAD DATA --

TRUNCATE TABLE pizza;
GO
BULK INSERT pizza
FROM 'D:\Excel Power BI\SQL Practice\SQL Project Case Study (Pizza Sales Analysis)\Datasets\pizzas.csv'
WITH ( FIRSTROW = 2,
	   FIELDTERMINATOR = ',',
	   ROWTERMINATOR = '\n',
	   TABLOCK );
GO

TRUNCATE TABLE order_detail;
GO
BULK INSERT order_detail
FROM 'D:\Excel Power BI\SQL Practice\SQL Project Case Study (Pizza Sales Analysis)\Datasets\order_details.csv'
WITH ( FIRSTROW = 2,
	   FIELDTERMINATOR = ',',
	   ROWTERMINATOR = '0x0a',
	   TABLOCK );
GO

TRUNCATE TABLE orders;
GO
SET DATEFORMAT dmy; 
GO
BULK INSERT orders
FROM 'D:\Excel Power BI\SQL Practice\SQL Project Case Study (Pizza Sales Analysis)\Datasets\orders.csv'
WITH ( FIRSTROW = 2,
	   FIELDTERMINATOR = ',',
	   ROWTERMINATOR = '0x0a',
	   TABLOCK );
GO

TRUNCATE TABLE type;
GO
BULK INSERT type
FROM 'D:\Excel Power BI\SQL Practice\SQL Project Case Study (Pizza Sales Analysis)\Datasets\pizza_types.csv'
WITH ( 
	   FORMAT = 'CSV',
	   FIRSTROW = 2,
	   FIELDTERMINATOR = ',',
	   FIELDQUOTE = '"',
	   ROWTERMINATOR = '0x0a',
	   TABLOCK );
GO






