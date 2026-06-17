USE [gravity_books]

--Book_Dim

SELECT
	b.book_id,
	b.title,
	b.isbn13,
	bl.language_id,
	bl.language_code,
	bl.language_name,
	b.num_pages,
	b.publication_date,
	p.publisher_id,
	p.publisher_name
FROM book b
LEFT JOIN book_language bl
ON bl.language_id = b.language_id
LEFT JOIN publisher p
ON p.publisher_id = b.publisher_id



--Author_Dim

SELECT
	a.author_id,
	a.author_name
FROM author	a


--Book_Author_Dim
/*
SELECT count(b.book_id), a.author_id
FROM book b
join book_author ba
on b.book_id = ba.book_id
join author a
on a.author_id = ba.author_id
group by a.author_id */


--Shipping_Dim

SELECT
	sm.method_id,
	sm.method_name,
	sm.cost
FROM shipping_method sm


--Customer_Dim

SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	c.email
FROM customer c


--Address_Dim

SELECT
	a.address_id,
	a.street_number,
	a.street_name,
	a.city,
	c.country_id,
	c.country_name
FROM [address] a
LEFT JOIN country c
ON c.country_id = a.country_id


--Customer_Address_Dim

SELECT
	ca.customer_id,
	ca.address_id,
	a.status_id,
	a.address_status
FROM customer_address ca
JOIN address_status a
ON a.status_id = ca.status_id


--Order_Dim

SELECT
	co.order_id,
	sm.method_id,
	sm.method_name,
	co.dest_address_id
FROM cust_order co
LEFT JOIN shipping_method sm
ON sm.method_id = co.shipping_method_id


--Status_Dim

SELECT
	os.status_id,
	os.status_value,
	CASE 
        WHEN Status_Value IN ('delivered', 'cancelled', 'returned') THEN 'finalized'
        ELSE 'active'
    END AS Status_Category,
	CASE 
        WHEN Status_Value IN ('delivered', 'cancelled', 'returned') THEN 1 
        ELSE 0 
    END AS Is_Terminal_State
FROM order_status os

--Orders_Fact
USE gravity_books 


SELECT co.customer_id,
	   ol.book_id,
	   co.order_id,
	   ol.line_id,
	   co.shipping_method_id,
	   co.order_date,
	   ol.price,
	   sm.cost
FROM cust_order co
JOIN order_line ol
ON co.order_id = ol.order_id
JOIN shipping_method sm
ON sm.method_id = co.shipping_method_id

--Order_History_Fact 

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