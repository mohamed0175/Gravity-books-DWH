--CREATE DATABASE [Gravity_Books_DWH]
--GO
USE [Gravity_Books_DWH]
GO

CREATE TABLE Book_Dim
(
	Book_SK INT IDENTITY (1, 1) PRIMARY KEY,
	Book_BK INT NOT NULL,
	Title VARCHAR(400),
	Isbn13 VARCHAR(13),
	Lang_BK INT NOT NULL,
	Lang_Code VARCHAR(8),
	Lang_Name VARCHAR(50),
	Num_Pages INT,
	Publication_Date DATE,
	Publisher_BK INT NOT NULL,
	Publisher_Name NVARCHAR(1000),
	Price DECIMAL(5,2)
)

GO

CREATE TABLE Author_Dim
(
	Author_SK INT IDENTITY (1, 1) PRIMARY KEY,
	Author_BK INT NOT NULL,
	Author_Name VARCHAR(400)
)

GO

CREATE TABLE Book_Author_Dim
(
	Book_SK_FK INT NOT NULL,
	Author_SK_FK INT NOT NULL,
	CONSTRAINT Book_Bridge FOREIGN KEY (Book_SK_FK) REFERENCES Book_Dim (Book_SK),
	CONSTRAINT Author_Bridge FOREIGN KEY (Author_SK_FK) REFERENCES Author_Dim (Author_SK)
)

GO

CREATE TABLE Shipping_Dim
(
	Method_SK INT IDENTITY (1, 1) PRIMARY KEY,
	Method_BK INT NOT NULL,
	Method_Name VARCHAR(100),
	Const DECIMAL(6,2)
)

GO

CREATE TABLE Customer_Dim
(
	Customer_SK INT IDENTITY (1, 1) PRIMARY KEY,
	Customer_BK INT NOT NULL,
	First_Name VARCHAR(200),
	Last_Name VARCHAR(200),
	Email VARCHAR(350)
)

GO

CREATE TABLE Address_Dim
(
	Address_SK INT IDENTITY (1, 1) PRIMARY KEY,
	Address_BK INT NOT NULL,
	Street_Number VARCHAR(10),
	Street_Name VARCHAR(200),
	City VARCHAR(100),
	Country_BK INT NOT NULL,
	Country_Name VARCHAR(200)
)

GO

CREATE TABLE Customer_Address_Dim
(
	Customer_SK_FK INT NOT NULL,
	Address_SK_FK INT NOT NULL,
	Status_BK INT NOT NULL,
	Address_Status VARCHAR(30),
	CONSTRAINT Customer_Bridge FOREIGN KEY (Customer_SK_FK) REFERENCES Customer_Dim (Customer_SK),
	CONSTRAINT Address_Bridge FOREIGN KEY (Address_SK_FK) REFERENCES Address_Dim (Address_SK)
)

GO

CREATE TABLE Orders_Fact
(
	Fact_SK INT IDENTITY (1, 1) PRIMARY KEY,
	Customer_SK_FK INT NOT NULL,
	Book_SK_FK INT NOT NULL,
	Order_ID_DD INT,
	History_ID_DD INT,
	Line_ID_DD INT,
	Shipping_Method_SK_FK INT NOT NULL,
	Order_Date_SK_FK INT NOT NULL,
	Order_Time_SK_FK INT NOT NULL,
	Total_Fee DECIMAL(7,2),
	CONSTRAINT Customer_Dim_FK FOREIGN KEY (Customer_SK_FK) REFERENCES Customer_Dim (Customer_SK),
	CONSTRAINT Book_Dim_FK FOREIGN KEY (Book_SK_FK) REFERENCES Book_Dim (Book_SK),
	CONSTRAINT Shipping_Dim_FK FOREIGN KEY (Shipping_Method_SK_FK) REFERENCES Shipping_Dim (Method_SK),
	CONSTRAINT Date_Dim_FK FOREIGN KEY (Order_Date_SK_FK) REFERENCES Date_Dim (Date_SK),
	CONSTRAINT Time_Dim_FK FOREIGN KEY (Order_Time_SK_FK) REFERENCES Time_Dim (Time_SK)
)

GO

CREATE TABLE Order_Dim
(
	Order_SK INT IDENTITY (1, 1) PRIMARY KEY,
	Order_ID_BK INT NOT NULL,
	Method_BK INT NOT NULL,
	Method_Name VARCHAR(100),
	Dest_Address_BK INT NOT NULL
)

GO

CREATE TABLE Status_Dim
(
	Status_SK INT IDENTITY (1, 1) PRIMARY KEY,
	Status_BK INT NOT NULL,
	Status_Value VARCHAR(20),
	Status_Category VARCHAR(10),
	Is_Terminal_State BIT NOT NULL
)

GO

CREATE TABLE Order_History_Fact
(
	Order_SK_FK INT NOT NULL,
	Received_Date_SK_FK INT NOT NULL DEFAULT -1,
	Pending_Date_SK_FK INT NOT NULL DEFAULT -1,
	In_Progress_Date_SK_FK INT NOT NULL DEFAULT -1,
	Delivered_Date_SK_FK INT NOT NULL DEFAULT -1,
	Cancelled_Date_SK_FK INT NOT NULL DEFAULT -1,
	Returned_Date_SK_FK INT NOT NULL DEFAULT -1,
	Current_Status_SK_FK INT NOT NULL,
	Days_of_Proceess INT,
	Days_of_Deliverd INT,
	CONSTRAINT Order_FK FOREIGN KEY (Order_SK_FK) REFERENCES Order_Dim (Order_SK),
	CONSTRAINT Received_Date_FK FOREIGN KEY (Received_Date_SK_FK) REFERENCES Date_Dim (Date_SK),
	CONSTRAINT Pending_Date_FK FOREIGN KEY (Pending_Date_SK_FK) REFERENCES Date_Dim (Date_SK),
	CONSTRAINT In_Progress_Date_FK FOREIGN KEY (In_Progress_Date_SK_FK) REFERENCES Date_Dim (Date_SK),
	CONSTRAINT Delivered_Date_FK FOREIGN KEY (Delivered_Date_SK_FK) REFERENCES Date_Dim (Date_SK),
	CONSTRAINT Cancelled_Date_FK FOREIGN KEY (Cancelled_Date_SK_FK) REFERENCES Date_Dim (Date_SK),
	CONSTRAINT Returned_Date_FK FOREIGN KEY (Returned_Date_SK_FK) REFERENCES Date_Dim (Date_SK),
	CONSTRAINT Current_Status_FK FOREIGN KEY (Current_Status_SK_FK) REFERENCES Status_Dim (Status_SK)
)

GO

ALTER TABLE Book_Dim
DROP COLUMN Price

GO

ALTER TABLE Orders_Fact
ADD Order_Price DECIMAL(5,2)

GO

ALTER TABLE Orders_Fact
ADD Order_Price DECIMAL(5,2)

GO

ALTER TABLE Shipping_Dim
ADD [Start_Date] DATE,
	[End_Date] DATE,
	Is_Current BIT DEFAULT 1

GO
ALTER TABLE Orders_Fact
DROP COLUMN History_ID_DD


/*
CREATE TABLE Stage_Customer
(
	Customer_id INT NOT NULL,
	First_Name VARCHAR(200),
	Last_Name VARCHAR(200),
	Email VARCHAR(350)
)*/

/*
CREATE TABLE Stage_Address
(
	Address_BK INT NOT NULL,
	Street_Number VARCHAR(10),
	Street_Name VARCHAR(200),
	City VARCHAR(100),
	Country_BK INT NOT NULL,
	Country_Name VARCHAR(200)
)*/

/*
CREATE TABLE Stage_Customer_Address
(
	Customer_SK_FK INT NOT NULL,
	Address_SK_FK INT NOT NULL,
	Status_BK INT NOT NULL,
	Address_Status VARCHAR(30),
)*/

/*
CREATE TABLE Stage_Order
(
	Order_ID_BK INT NOT NULL,
	Method_BK INT NOT NULL,
	Method_Name VARCHAR(100),
	Dest_Address_BK INT NOT NULL
)*/

/*
CREATE TABLE Stage_Order_History_Fact
(
	Order_SK_FK INT NOT NULL,
	Received_Date_SK_FK INT NOT NULL DEFAULT -1,
	Pending_Date_SK_FK INT NOT NULL DEFAULT -1,
	In_Progress_Date_SK_FK INT NOT NULL DEFAULT -1,
	Delivered_Date_SK_FK INT NOT NULL DEFAULT -1,
	Cancelled_Date_SK_FK INT NOT NULL DEFAULT -1,
	Returned_Date_SK_FK INT NOT NULL DEFAULT -1,
	Current_Status_SK_FK INT NOT NULL,
	Days_of_Proceess INT,
	Days_of_Deliverd INT
)*/

/*  --to handle null values in the history order fact
INSERT INTO Date_Dim (Date_SK,
                      [Date],
                      [Day],
                      DaySuffix,
                      [DayOfWeek],
                      DOWInMonth,
                      [DayOfYear],
                      [WeekOfYear],
                      [WeekOfMonth],
                      [Month],
                      [MonthName],
                      [Quarter],
                      [QuarterName],
                      [Year],
                      [StandardDate],
                      [Holiday_name_en],
                      [Holiday_name_ar]) -- Use your actual column names
VALUES (-1, '1900-01-01', '01', '1st', 'asNull', 1, 1, 1, 1, '01', 'asNull', 1, 'asNull', '1900', '01/01/1900', 'asNull', 'asNull');
*/