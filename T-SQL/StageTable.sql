--CREATE DATABASE olistDWStage
USE olistDWStage

-- 1. stgCustomer
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
INTO olistDWStage.dbo.stgCustomers
FROM olistdb.dbo.Customers;


-- 2. stgGeolocation
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
INTO olistDWStage.dbo.stgGeolocation
FROM olistdb.dbo.Geolocation;


-- 3. stgProducts
SELECT
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
INTO olistDWStage.dbo.stgProducts
FROM olistdb.dbo.Products;


--4. stage seller
SELECT seller_id
      , seller_zip_code_prefix
      ,seller_city
      ,seller_state
	into [dbo].[stgSellers]
  FROM [olistdb].[dbo].[Sellers]


--5. stage order
SELECT order_id
	  ,o.customer_id
      ,order_status
      ,order_purchase_timestamp
      ,order_approved_at
      ,order_delivered_carrier_date
      ,order_delivered_customer_date
      ,order_estimated_delivery_date
	into [dbo].[stgOrders]
  FROM [olistdb].[dbo].[Orders] o
	join [olistdb].[dbo].[Customers] c
		on o.customer_id = c.customer_id




--6. stage order_item
SELECT ot.order_id
	  ,order_item_id
      ,ot.product_id
      ,ot.seller_id
      ,shipping_limit_date
      ,price
      ,freight_value
	into [dbo].[stgOrderItems]
  FROM [olistdb].[dbo].[Order_Items] ot
  join [olistdb].[dbo].[Orders] o
	on ot.order_id = o.order_id
	join [olistdb].[dbo].[Products] p
	on ot.product_id = p.product_id
	join [olistdb].[dbo].[Sellers] s
	on ot.seller_id = s.seller_id


--7. Staging Order_Payments
SELECT 
    order_id, 
    payment_sequential, 
    payment_type, 
    payment_installments, 
    payment_value
INTO [dbo].[stgOrderPayments]
FROM [olistdb].[dbo].[Order_Payments];

go
--8. staging Order_Reviews
SELECT 
    review_id, 
    order_id, 
    review_score, 
    review_comment_title, 
    review_comment_message, 
    review_creation_date, 
    review_answer_timestamp
INTO [dbo].[stgOrderReviews]
FROM [olistdb].[dbo].[Order_Reviews];

go
--9. Staging Date
SELECT *
INTO [dbo].[stgDate]
FROM [olistdb].[dbo].[DimDate];

-- 10. Staging FactSales
SELECT 
    oi.order_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_purchase_timestamp AS order_date,
    op.payment_sequential,
    oi.order_item_id,
    oi.price,
    oi.freight_value
INTO dbo.stgFactSales
FROM olistdb.dbo.Order_Items oi
JOIN olistdb.dbo.Orders o ON oi.order_id = o.order_id
JOIN olistdb.dbo.Order_Payments op ON o.order_id = op.order_id;



-- 11. Staging FactOrder
SELECT
    so.order_id,
    so.customer_id,
    so.order_purchase_timestamp,
    so.order_approved_at,
    so.order_delivered_customer_date,
    so.order_estimated_delivery_date,
    DATEDIFF(DAY, so.order_purchase_timestamp, so.order_delivered_customer_date) AS delivery_time,
    DATEDIFF(DAY, so.order_purchase_timestamp, so.order_approved_at) AS order_processing_time,
    DATEDIFF(DAY, so.order_estimated_delivery_date, so.order_delivered_customer_date) AS delivery_delay,
    COUNT(soi.order_item_id) AS order_item_count
INTO olistDWStage.dbo.stgFactOrders
FROM olistdb.dbo.Orders so
LEFT JOIN olistdb.dbo.Order_items soi ON so.order_id = soi.order_id
GROUP BY
    so.order_id,
    so.customer_id,
    so.order_purchase_timestamp,
    so.order_approved_at,
    so.order_delivered_customer_date,
    so.order_estimated_delivery_date;





-- 12. Staging FactReviews
SELECT
    sr.review_id,
    sr.order_id,
    so.customer_id,
    soi.seller_id,
    soi.product_id,
    CAST(sr.review_creation_date AS DATE) AS review_date,
    sr.review_score,
    CASE WHEN sr.review_score <= 2 THEN 1 ELSE 0 END AS is_negative_review,
    LEN(ISNULL(sr.review_comment_message, '')) AS review_comment_length,
    CASE 
        WHEN sr.review_comment_message IS NOT NULL AND LEN(LTRIM(RTRIM(sr.review_comment_message))) > 0 
        THEN 1 ELSE 0 
    END AS has_comment
INTO stgFactReviews
FROM olistdb.dbo.Order_reviews sr
JOIN olistdb.dbo.Orders so ON sr.order_id = so.order_id
JOIN olistdb.dbo.Order_items soi ON sr.order_id = soi.order_id;

