select *
from order_line as ol
left join cust_order as co
on co.order_id = ol.order_id
left join order_history as oh
on co.order_id = oh.order_id
left join order_status as os
on os.status_id = oh.status_id


select count(*)
from cust_order as co
join order_history as oh
on co.order_id = oh.order_id


select *
from cust_order as co
join order_history as oh
on co.order_id = oh.order_id
where oh.status_date = co.order_date


select count(*) from order_line

select count(distinct book_id) from order_line

select count(distinct order_id) from order_line

select count(isbn13) from book
select distinct count(isbn13) from book

SELECT *
FROM (
    SELECT *, 
           COUNT(*) OVER (PARTITION BY order_id) as cnt
    FROM order_line
) sub
WHERE cnt > 1
ORDER BY order_id;

select *
from order_line as co

select * from order_history as oh
left join order_status as os
on os.status_id = oh.status_id

select * from order_status as os

use Gravity_Books_DWH

select avg(Price) from Book_Dim

select * from Book_Dim

where Price is null

update Book_Dim
set Price = (select AVG(Price) from Book_Dim)
where Price is null

DELETE FROM Book_Dim
DBCC CHECKIDENT ('Book_Dim', RESEED, 0)

DELETE FROM Book_Author_Dim
DBCC CHECKIDENT ('Book_Author_Dim', RESEED, 0)

use Gravity_Books_DWH
select *
from Customer_Address_Dim

DELETE FROM Customer_Dim
DBCC CHECKIDENT ('Customer_Dim', RESEED, 0)

use gravity_books
--select * from customer
select * from customer_address

select *
from Shipping_Dim

use Gravity_Books_DWH
select * from Status_Dim

DELETE FROM Shipping_Dim
DBCC CHECKIDENT ('Shipping_Dim', RESEED, 0)

select *
from Book_Author_Dim

select *
from Author_Dim

use gravity_books

select *
from book_author


use gravity_books

select *
from customer_address ca
join address_status a
on a.status_id = ca.status_id

/*
MERGE Customer_Dim AS [Target]
USING Stage_Customer AS Source
ON (Target.Customer_BK = Source.Customer_id) -- Match on Natural Key

WHEN MATCHED AND (Target.Email <> Source.Email) THEN
    -- Update existing record if something changed
    UPDATE SET 
        Target.Email = Source.Email,
        --Target.Last_Updated = GETDATE()

WHEN NOT MATCHED BY TARGET THEN
    -- Insert new record
    INSERT (Customer_BK, First_Name, Last_Name, Email)
    VALUES (Source.Customer_id, Source.First_Name, Source.Last_Name, Source.Email);


MERGE Address_Dim AS [Target] 
USING Stage_Address AS Source
ON (Target.Address_BK = Source.Address_BK)
WHEN NOT MATCHED BY TARGET THEN 
INSERT (Address_BK, Street_Number, Street_Name, City, Country_BK, Country_Name) 
VALUES (Source.Address_BK,
        Source.Street_Number,
        Source.Street_Name,
        Source.City,
        Source.Country_BK,
        Source.Country_Name);


MERGE Customer_Address_Dim AS [Target] 
USING Stage_Customer_Address AS Source
ON (Target.Customer_SK_FK = Source.Customer_SK_FK AND Target.Address_SK_FK = Source.Address_SK_FK)

WHEN NOT MATCHED BY TARGET THEN
INSERT (Customer_SK_FK, Address_SK_FK, Status_BK, Address_Status) 
VALUES (Source.Customer_SK_FK,
        Source.Address_SK_FK,
        Source.Status_BK,
        Source.Address_Status);

*/

--EXEC sp_rename 'Orders_Fact.const', 'Total_Fee', 'COLUMN';

/*
use Gravity_Books_DWH

select * from Orders_Fact
DELETE FROM Orders_Fact
DBCC CHECKIDENT ('Orders_Fact', RESEED, 0)

SELECT
    ISNULL(MAX(CAST(D.[Date] AS DATETIME) + CAST(T.[Time] AS DATETIME)), '1900-01-01')

FROM Orders_Fact O
JOIN Date_Dim D ON D.Date_SK = O.Order_Date_SK_FK
JOIN Time_Dim T ON T.Time_SK = O.Order_Time_SK_FK

use gravity_books
select * from cust_order
where order_id = 3

SELECT 
    ISNULL(MAX(CAST(CONCAT(FORMAT(D.[Date], 'yyyy-MM-dd'), ' ', FORMAT(T.[Time], 'HH:mm:ss')) AS DATETIME2(0))), '1900-01-01')
FROM Orders_Fact O
JOIN Date_Dim D ON D.Date_SK = O.Order_Date_SK_FK
JOIN Time_Dim T ON T.Time_SK = O.Order_Time_SK_FK

*/
/*
MERGE Order_Dim AS [Target] 
USING Stage_Order AS Source
ON (Target.Order_ID_BK = Source.Order_ID_BK)
WHEN MATCHED AND (Target.Method_Name <> Source.Method_Name) THEN
UPDATE SET  
Target.Method_Name = Source.Method_Name, 

WHEN NOT MATCHED BY TARGET THEN
INSERT (Order_ID_BK, Method_BK, Method_Name, Dest_Address_BK) 
VALUES (Source.Order_ID_BK, Source.Method_BK, Source.Method_Name, Source.Dest_Address_BK);
*/

use gravity_books

select order_id,
       status_id,
       status_date
from order_history
order by order_id, status_id

create view dbo.History_Fact_Source
as
select order_id,
       status_id,
       min(status_date) as status_date
from order_history
group by order_id, status_id

--order by order_id, status_id


use Gravity_Books_DWH
select * from Date_Dim

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

select * from Stage_Order_History_Fact

MERGE Fact_Order_Accumulating AS Target
USING Stage_Fact AS Source
ON (Target.Order_Business_Key = Source.Order_Business_Key)

WHEN MATCHED THEN
    UPDATE SET 
        Target.Ship_Date_SK = Source.Ship_Date_SK,
        Target.Delivery_Date_SK = Source.Delivery_Date_SK,
        Target.Current_Status = Source.Current_Status,
        Target.Total_Duration = Source.Total_Duration, -- Updated calculation
        Target.Last_Updated = GETDATE()

WHEN NOT MATCHED THEN
    INSERT (Order_Business_Key, Order_Date_SK, Ship_Date_SK, Current_Status, Total_Duration)
    VALUES (Source.Order_Business_Key, Source.Order_Date_SK, Source.Ship_Date_SK, Source.Current_Status, Source.Total_Duration);


SELECT 
    order_id,
    MAX(CASE WHEN status_id = 1 THEN status_date END) AS Received_Date,
    MAX(CASE WHEN status_id = 2 THEN status_date END) AS Pending_Date,
    MAX(CASE WHEN status_id = 3 THEN status_date END) AS InProgress_Date,
    MAX(CASE WHEN status_id = 4 THEN status_date END) AS Delivered_Date,
    MAX(CASE WHEN status_id = 5 THEN status_date END) AS Cancelled_Date,
    MAX(CASE WHEN status_id = 6 THEN status_date END) AS Returned_Date,
    MAX(status_id) AS Current_Status
FROM History_Fact_Source
GROUP BY order_id
/*
create view dbo.History_Fact_Source
as
select order_id,
       status_id,
       min(status_date) as status_date
from order_history
group by order_id, status_id*/
use Gravity_Books_DWH
select * from Book_Dim
DELETE FROM Status_Dim
DBCC CHECKIDENT ('Status_Dim', RESEED, 0)

---------------- preventing duplication in order history fact and add measures ---------------

/*
MERGE Order_History_Fact AS Target
USING (
    SELECT 
        s.*, 
        d1.[Date] AS Received_Date, 
        d3.[Date] AS In_Progress_Date,
        d2.[Date] AS Delivered_Date
    FROM Stage_Order_History_Fact s
    LEFT JOIN Date_Dim d1 ON s.Received_Date_SK_FK = d1.Date_SK
    LEFT JOIN Date_Dim d2 ON s.In_Progress_Date_SK_FK = d2.Date_SK
    LEFT JOIN Date_Dim d3 ON s.Delivered_Date_SK_FK = d3.Date_SK
) AS Source
ON Target.Order_SK_FK = Source.Order_SK_FK

WHEN MATCHED THEN
    UPDATE SET 
        Target.Received_Date_SK_FK = Source.Received_Date_SK_FK,
        Target.Pending_Date_SK_FK = Source.Pending_Date_SK_FK,
        Target.In_Progress_Date_SK_FK = Source.In_Progress_Date_SK_FK,
        Target.Delivered_Date_SK_FK = Source.Delivered_Date_SK_FK,
        Target.Cancelled_Date_SK_FK = Source.Cancelled_Date_SK_FK,
        Target.Returned_Date_SK_FK = Source.Returned_Date_SK_FK,
        Target.Current_Status_SK_FK = Source.Current_Status_SK_FK,
        Target.Days_of_Deliverd = CASE 
            WHEN Source.Delivered_Date > '1900-01-01' AND Source.Received_Date > '1900-01-01'
            THEN DATEDIFF(day, Source.Received_Date, Source.Delivered_Date) 
            ELSE NULL 
        END,
        Target.Days_of_Proceess = CASE 
            WHEN Source.In_Progress_Date > '1900-01-01' AND Source.Received_Date > '1900-01-01'
            THEN DATEDIFF(day, Source.Received_Date, Source.In_Progress_Date) 
            ELSE NULL 
        END

WHEN NOT MATCHED THEN
    INSERT (Order_SK_FK,
            Received_Date_SK_FK,
            Pending_Date_SK_FK,
            In_Progress_Date_SK_FK,
            Delivered_Date_SK_FK,
            Cancelled_Date_SK_FK,
            Returned_Date_SK_FK,
            Current_Status_SK_FK,
            Days_of_Proceess,
            Days_of_Deliverd)
    VALUES (Source.Order_SK_FK,
            Source.Received_Date_SK_FK,
            Source.Pending_Date_SK_FK,
            Source.In_Progress_Date_SK_FK,
            Source.Delivered_Date_SK_FK,
            Source.Cancelled_Date_SK_FK,
            Source.Returned_Date_SK_FK,
            Source.Current_Status_SK_FK,
            CASE 
                WHEN Source.In_Progress_Date > '1900-01-01' AND Source.Received_Date > '1900-01-01'
                THEN DATEDIFF(day, Source.Received_Date, Source.In_Progress_Date) 
                ELSE NULL 
            END,
            CASE 
                WHEN Source.Delivered_Date > '1900-01-01' AND Source.Received_Date > '1900-01-01'
                THEN DATEDIFF(day, Source.Received_Date, Source.Delivered_Date) 
                ELSE NULL 
            END);
*/





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
