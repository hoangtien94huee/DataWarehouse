USE olistDWStage

-- 1. dimCustomers
MERGE INTO olistDW.dbo.DimCustomers AS target
USING stgCustomers AS source
ON target.customer_id = source.customer_id AND target.RowIsCurrent = 1

-- Khi có thay đổi dữ liệu
WHEN MATCHED AND (
    ISNULL(target.customer_unique_id, '') <> ISNULL(source.customer_unique_id, '') OR
    ISNULL(target.customer_zip_code_prefix, -1) <> ISNULL(source.customer_zip_code_prefix, -1) OR
    ISNULL(target.customer_city, '') <> ISNULL(source.customer_city, '') OR
    ISNULL(target.customer_state, '') <> ISNULL(source.customer_state, '')
)
THEN
    UPDATE SET
        target.RowIsCurrent = 0,
        target.RowEndDate = GETDATE(),
        target.RowChangeReason = 'Changed in source'


-- Khi không tìm thấy bản ghi đang hoạt động (dữ liệu mới)
WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        RowIsCurrent,
        RowStartDate
    )
    VALUES (
        source.customer_id,
        source.customer_unique_id,
        source.customer_zip_code_prefix,
        source.customer_city,
        source.customer_state,
        1,
        GETDATE()
    );

-- 2. DimGeolocation
MERGE INTO olistDW.dbo.DimGeolocation AS target
USING stgGeolocation AS source
ON target.geolocation_zip_code_prefix = source.geolocation_zip_code_prefix AND target.RowIsCurrent = 1

WHEN MATCHED AND (
    ISNULL(target.geolocation_lat, -1) <> ISNULL(source.geolocation_lat, -1) OR
    ISNULL(target.geolocation_lng, -1) <> ISNULL(source.geolocation_lng, -1) OR
    ISNULL(target.geolocation_city, '') <> ISNULL(source.geolocation_city, '') OR
    ISNULL(target.geolocation_state, '') <> ISNULL(source.geolocation_state, '')
)
THEN
    UPDATE SET
        target.RowIsCurrent = 0,
        target.RowEndDate = GETDATE(),
        target.RowChangeReason = 'Changed in source'

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state,
        RowIsCurrent,
        RowStartDate
    )
    VALUES (
        source.geolocation_zip_code_prefix,
        source.geolocation_lat,
        source.geolocation_lng,
        source.geolocation_city,
        source.geolocation_state,
        1,
        GETDATE()
    );


-- 3. dimProducts
MERGE INTO olistDW.dbo.DimProducts AS target
USING stgProducts AS source
ON target.product_id = source.product_id AND target.RowIsCurrent = 1

WHEN MATCHED AND (
    ISNULL(target.product_category_name, '') <> ISNULL(source.product_category_name, '') OR
    ISNULL(target.product_name_lenght, 0) <> ISNULL(source.product_name_lenght, 0) OR
    ISNULL(target.product_description_lenght, 0) <> ISNULL(source.product_description_lenght, 0) OR
    ISNULL(target.product_photos_qty, 0) <> ISNULL(source.product_photos_qty, 0) OR
    ISNULL(target.product_weight_g, 0) <> ISNULL(source.product_weight_g, 0) OR
    ISNULL(target.product_length_cm, 0) <> ISNULL(source.product_length_cm, 0) OR
    ISNULL(target.product_height_cm, 0) <> ISNULL(source.product_height_cm, 0) OR
    ISNULL(target.product_width_cm, 0) <> ISNULL(source.product_width_cm, 0)
)
THEN
    UPDATE SET
        target.RowIsCurrent = 0,
        target.RowEndDate = GETDATE(),
        target.RowChangeReason = 'Changed in source'

WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        product_id,
        product_category_name,
        product_name_lenght,
        product_description_lenght,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        RowIsCurrent,
        RowStartDate
    )
    VALUES (
        source.product_id,
        source.product_category_name,
        source.product_name_lenght,
        source.product_description_lenght,
        source.product_photos_qty,
        source.product_weight_g,
        source.product_length_cm,
        source.product_height_cm, 
        source.product_width_cm,
        1,
        GETDATE()
    );




-- 4. Load DimSeller
MERGE INTO olistDW.dbo.DimSellers AS target
USING olistDWStage.dbo.stgSellers AS source
ON target.seller_id = source.seller_id AND target.RowIsCurrent = 1

-- Khi có thay đổi dữ liệu → cập nhật bản ghi cũ
WHEN MATCHED AND (
    ISNULL(target.seller_zip_code_prefix, -1) <> ISNULL(source.seller_zip_code_prefix, -1) OR
    ISNULL(target.seller_city, '') <> ISNULL(source.seller_city, '') OR
    ISNULL(target.seller_state, '') <> ISNULL(source.seller_state, '')
)
THEN
    UPDATE SET
        target.RowIsCurrent = 0,
        target.RowEndDate = GETDATE(),
        target.RowChangeReason = 'Changed in source'

-- Khi là bản ghi mới → thêm mới vào bảng dim
WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state,
        RowIsCurrent,
        RowStartDate
    )
    VALUES (
        source.seller_id,
        source.seller_zip_code_prefix,
        source.seller_city,
        source.seller_state,
        1,
        GETDATE()
    );


-- 5. Load DimOrders
MERGE INTO olistDW.dbo.DimOrders AS target
USING olistDWStage.dbo.stgOrders AS source
ON target.order_id = source.order_id AND target.RowIsCurrent = 1

-- Khi có thay đổi dữ liệu → SCD Type 2: Đánh dấu bản ghi cũ
WHEN MATCHED AND (
    ISNULL(target.order_status, '') <> ISNULL(source.order_status, '')
)
THEN UPDATE SET
    target.RowIsCurrent = 0,
    target.RowEndDate = GETDATE(),
    target.RowChangeReason = 'Changed in source'

-- Khi bản ghi chưa từng tồn tại → Thêm mới
WHEN NOT MATCHED BY TARGET
THEN
INSERT (
    order_id,
	customer_id,
    order_status,
	order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    RowIsCurrent,
    RowStartDate
)
VALUES (
    source.order_id,
	source.customer_id,
    source.order_status,
	source.order_purchase_timestamp,
    source.order_approved_at,
    source.order_delivered_carrier_date,
    source.order_delivered_customer_date,
    source.order_estimated_delivery_date,
    1,
    GETDATE()
);


-- 6. Load dimOrderItems
MERGE INTO olistDW.dbo.DimOrderItem AS target
USING olistDWStage.dbo.stgOrderItems AS source
ON target.order_item_id = source.order_item_id AND target.RowIsCurrent = 1 AND target.order_id = source.order_id

-- Khi có thay đổi dữ liệu → cập nhật bản ghi cũ (Type 2)
WHEN MATCHED AND (
    ISNULL(target.product_id, '') <> ISNULL(source.product_id, '') OR
    ISNULL(target.seller_id, '') <> ISNULL(source.seller_id, '') OR
    ISNULL(target.shipping_limit_date, '1900-01-01') <> ISNULL(source.shipping_limit_date, '1900-01-01') OR
    ISNULL(target.price, -1) <> ISNULL(source.price, -1) OR
    ISNULL(target.freight_value, -1) <> ISNULL(source.freight_value, -1)
)
THEN
    UPDATE SET
        target.RowIsCurrent = 0,
        target.RowEndDate = GETDATE(),
        target.RowChangeReason = 'Changed in source'

-- Khi chưa có bản ghi (mới hoàn toàn)
WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
		order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value,
        RowIsCurrent,
        RowStartDate
    )
    VALUES (
		source.order_id,
        source.order_item_id,
        source.product_id,
        source.seller_id,
        source.shipping_limit_date,
        source.price,
        source.freight_value,
        1,
        GETDATE()
    );




-- 7. Load DimOrderPayment
MERGE INTO olistDW.dbo.DimOrderPayment AS target
USING [olistDWStage].[dbo].stgOrderPayments AS source
ON 
    target.order_id = source.order_id AND
    target.payment_sequential = source.payment_sequential AND
    target.RowIsCurrent = 1

-- Khi có thay đổi dữ liệu
WHEN MATCHED AND (
    ISNULL(target.payment_type, '') <> ISNULL(source.payment_type, '') OR
    ISNULL(target.payment_installments, -1) <> ISNULL(source.payment_installments, -1) OR
    ISNULL(target.payment_value, -1) <> ISNULL(source.payment_value, -1)
)
THEN
    UPDATE SET
        target.RowIsCurrent = 0,
        target.RowEndDate = GETDATE(),
        target.RowChangeReason = 'Changed in source'

-- Khi không tìm thấy bản ghi (dữ liệu mới)
WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value,
        RowIsCurrent,
        RowStartDate,
        RowEndDate,
        RowChangeReason
    )
    VALUES (
        source.order_id,
        source.payment_sequential,
        source.payment_type,
        source.payment_installments,
        source.payment_value,
        1,
        GETDATE(),
        '9999-12-31',
        'Initial load or new change'
    );

-- 8. Load DimOrderReview
MERGE INTO olistDW.dbo.DimOrderReview AS target
USING [olistDWStage].[dbo].stgOrderReviews AS source
ON 
    target.review_id = source.review_id AND
	target.order_id = source.order_id AND
    target.RowIsCurrent = 1

-- Khi có thay đổi dữ liệu
WHEN MATCHED AND (
    ISNULL(target.order_id, '') <> ISNULL(source.order_id, '') OR
    ISNULL(target.review_score, -1) <> ISNULL(source.review_score, -1) OR
    ISNULL(target.review_comment_title, '') <> ISNULL(source.review_comment_title, '') OR
    ISNULL(target.review_comment_message, '') <> ISNULL(source.review_comment_message, '')
)
THEN
    UPDATE SET
        target.RowIsCurrent = 0,
        target.RowEndDate = GETDATE(),
        target.RowChangeReason = 'Changed in source'

-- Khi không tìm thấy bản ghi (tức là dữ liệu mới)
WHEN NOT MATCHED BY TARGET
THEN
    INSERT (
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
		review_creation_date,
		review_answer_timestamp,
        RowIsCurrent,
        RowStartDate,
        RowEndDate,
        RowChangeReason
    )
    VALUES (
        source.review_id,
        source.order_id,
        source.review_score,
        source.review_comment_title,
        source.review_comment_message,
		source.review_creation_date,
		source.review_answer_timestamp,
        1,
        GETDATE(),
        '9999-12-31',
        'Initial load or new record'
    );

--9. Load DimDate
MERGE INTO olistDW.dbo.DimDate AS target
USING [olistDWStage].[dbo].stgDate AS source
ON target.date_key = source.date_key

WHEN MATCHED THEN
    UPDATE SET
        full_date = source.full_date,
        day_of_week = source.day_of_week,
        day_num_in_month = source.day_num_in_month,
        day_num_overall = source.day_num_overall,
        day_name = source.day_name,
        day_abbrev = source.day_abbrev,
        weekday_flag = source.weekday_flag,
        week_num_in_year = source.week_num_in_year,
        week_num_overall = source.week_num_overall,
        week_begin_date = source.week_begin_date,
        week_begin_date_key = source.week_begin_date_key,
        month = source.month,
        month_num_overall = source.month_num_overall,
        month_name = source.month_name,
        month_abbrev = source.month_abbrev,
        quarter = source.quarter,
        year = source.year,
        yearmo = source.yearmo,
        fiscal_month = source.fiscal_month,
        fiscal_quarter = source.fiscal_quarter,
        fiscal_year = source.fiscal_year,
        last_day_in_month_flag = source.last_day_in_month_flag,
        same_day_year_ago_date = source.same_day_year_ago_date

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        date_key, full_date, day_of_week, day_num_in_month, day_num_overall, day_name, day_abbrev,
        weekday_flag, week_num_in_year, week_num_overall, week_begin_date, week_begin_date_key,
        month, month_num_overall, month_name, month_abbrev, quarter, year, yearmo,
        fiscal_month, fiscal_quarter, fiscal_year, last_day_in_month_flag, same_day_year_ago_date
    )
    VALUES (
        source.date_key, source.full_date, source.day_of_week, source.day_num_in_month, source.day_num_overall, source.day_name, source.day_abbrev,
        source.weekday_flag, source.week_num_in_year, source.week_num_overall, source.week_begin_date, source.week_begin_date_key,
        source.month, source.month_num_overall, source.month_name, source.month_abbrev, source.quarter, source.year, source.yearmo,
        source.fiscal_month, source.fiscal_quarter, source.fiscal_year, source.last_day_in_month_flag, source.same_day_year_ago_date
    );

-- 10. Load FactSales
INSERT INTO olistDW.dbo.FactSales (
    orderKey,
    customerKey,
    productKey,
    sellerKey,
    dateKey,
    paymentKey,
    orderItemKey,
    price,
    totalOrderValue
)
SELECT
    do.orderKey,
    dc.customerKey,
    dp.productKey,
    ds.sellerKey,
    dd.date_key,
    dop.orderPaymentKey,
    doi.orderItemKey,
    s.price,
    s.price + s.freight_value AS totalOrderValue
FROM stgFactSales s
JOIN olistDW.dbo.DimOrders do ON s.order_id = do.order_id
JOIN olistDW.dbo.DimCustomers dc ON s.customer_id = dc.customer_id
JOIN olistDW.dbo.DimProducts dp ON s.product_id = dp.product_id
JOIN olistDW.dbo.DimSellers ds ON s.seller_id = ds.seller_id
JOIN olistDW.dbo.DimDate dd ON CONVERT(DATE, s.order_date) = dd.full_date
JOIN olistDW.dbo.DimOrderPayment dop ON s.order_id = dop.order_id AND s.payment_sequential = dop.payment_sequential
JOIN olistDW.dbo.DimOrderItem doi ON s.order_id = doi.order_id AND s.order_item_id = doi.order_item_id;

USE olistDW;
GO
SELECT COUNT(*) 
FROM olistDWStage.dbo.stgFactOrders sfo
JOIN olistDW.dbo.DimOrders dof 
    ON sfo.order_id = dof.order_id AND dof.RowIsCurrent = 1;


-- 11. Load FactOrders
-- Tính sẵn các cột DATE để tránh dùng CAST trong JOIN
WITH CleanedData AS (
    SELECT TOP 10
        sfo.order_id,
        sfo.customer_id,
        sfo.order_purchase_timestamp,
        sfo.order_approved_at,
        sfo.order_delivered_customer_date,
        sfo.order_estimated_delivery_date,
        sfo.delivery_time,
        sfo.order_processing_time,
        sfo.delivery_delay,
        sfo.order_item_count,
        CAST(sfo.order_purchase_timestamp AS DATE) AS order_date,
        CAST(sfo.order_approved_at AS DATE) AS approved_date,
        CAST(sfo.order_delivered_customer_date AS DATE) AS delivered_date,
        CAST(sfo.order_estimated_delivery_date AS DATE) AS estimated_date,
        dc.customerKey,
        dof.orderKey,
        dop.orderPaymentKey
    FROM olistDWStage.dbo.stgFactOrders sfo
    JOIN olistDW.dbo.DimOrders dof ON sfo.order_id = dof.order_id AND dof.RowIsCurrent = 1
    JOIN olistDW.dbo.DimCustomers dc ON sfo.customer_id = dc.customer_id AND dc.RowIsCurrent = 1
    JOIN olistDW.dbo.DimOrderPayment dop ON sfo.order_id = dop.order_id AND dop.RowIsCurrent = 1
)
INSERT INTO [olistDW].[dbo].FactOrders (
    customerKey,
    orderKey,
    orderDateKey,
    approvedDateKey,
    deliveryDateKey,
    estimatedDeliveryDateKey,
    orderPaymentKey,
    delivery_time,
    order_processing_time,
    delivery_delay,
    order_item_count
)
SELECT
    c.customerKey,
    c.orderKey,
    dd_order.date_key,
    dd_approved.date_key,
    dd_delivered.date_key,
    dd_estimated.date_key,
    c.orderPaymentKey,
    c.delivery_time,
    c.order_processing_time,
    c.delivery_delay,
    c.order_item_count
FROM CleanedData c
JOIN olistDW.dbo.DimDate dd_order ON c.order_date = dd_order.full_date
JOIN olistDW.dbo.DimDate dd_approved ON c.approved_date = dd_approved.full_date
JOIN olistDW.dbo.DimDate dd_delivered ON c.delivered_date = dd_delivered.full_date
JOIN olistDW.dbo.DimDate dd_estimated ON c.estimated_date = dd_estimated.full_date;



-- 12. Load FactReview
INSERT INTO olistDW.dbo.FactReview (
    reviewKey,
    customerKey,
    sellerKey,
    productKey,
    dateKey,
    orderKey,
    review_score,
    is_negative_review,
    review_comment_length,
    has_comment
)
SELECT
    dor.reviewKey,
    dc.customerKey,
    ds.sellerKey,
    dp.productKey,
    dd.date_key,
    dof.orderKey,
    sfr.review_score,
    sfr.is_negative_review,
    sfr.review_comment_length,
    sfr.has_comment
FROM stgFactReview sfr
JOIN olistDW.dbo.DimOrderReview dor ON sfr.review_id = dor.review_id AND dor.RowIsCurrent = 1
JOIN olistDW.dbo.DimOrders dof ON sfr.order_id = dof.order_id AND dof.RowIsCurrent = 1
JOIN olistDW.dbo.DimCustomers dc ON dof.customer_id = dc.customer_id AND dc.RowIsCurrent = 1
JOIN olistDW.dbo.DimSellers ds ON sfr.seller_id = ds.seller_id AND ds.RowIsCurrent = 1
JOIN olistDW.dbo.DimProducts dp ON sfr.product_id = dp.product_id AND dp.RowIsCurrent = 1
JOIN olistDW.dbo.DimDate dd ON sfr.review_date = dd.full_date;
