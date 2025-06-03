CREATE DATABASE olistDW
GO
USE olistDW;

CREATE TABLE DimCustomers (
    customerKey INT IDENTITY(1,1) PRIMARY KEY,  -- Khóa thay thế (surrogate key)
    customer_id NVARCHAR(50) NOT NULL,          -- Mã khách hàng trong hệ thống Olist
    customer_unique_id NVARCHAR(50),            -- Mã định danh vĩnh viễn (nếu một người có nhiều đơn hàng)
    customer_zip_code_prefix INT,          -- Mã vùng ZIP
    customer_city NVARCHAR(50) NULL,            -- Thành phố
    customer_state NVARCHAR(50) NULL,           -- Bang / Tỉnh
	RowIsCurrent bit  DEFAULT 1 NOT NULL,
    RowStartDate datetime  DEFAULT '12/31/1899' NOT NULL,
    RowEndDate  datetime  DEFAULT '12/31/9999' NOT NULL,
    RowChangeReason nvarchar(200)  DEFAULT '12/31/1899' NULL
);
GO

CREATE TABLE DimGeolocation (
    geoKey INT IDENTITY(1,1) PRIMARY KEY,              -- Khóa thay thế
    geolocation_zip_code_prefix INT NOT NULL,         -- Mã ZIP
    geolocation_lat FLOAT NULL,                       -- Vĩ độ
    geolocation_lng FLOAT NULL,                       -- Kinh độ
    geolocation_city NVARCHAR(50) NULL,               -- Thành phố
    geolocation_state NVARCHAR(50) NOT NULL,           -- Bang
	RowIsCurrent bit  DEFAULT 1 NOT NULL,
    RowStartDate datetime  DEFAULT '12/31/1899' NOT NULL,
    RowEndDate  datetime  DEFAULT '12/31/9999' NOT NULL,
    RowChangeReason nvarchar(200)  DEFAULT '12/31/1899' NULL
);
GO

CREATE TABLE DimProducts (
    productKey INT IDENTITY(1,1) PRIMARY KEY,         -- Khóa thay thế
    product_id NVARCHAR(50) NOT NULL,                 -- ID gốc từ hệ thống Olist
    product_category_name NVARCHAR(50) NULL,          -- Tên danh mục sản phẩm
    product_name_lenght TINYINT NULL,                 -- Độ dài tên sản phẩm
    product_description_lenght SMALLINT NULL,         -- Độ dài mô tả
    product_photos_qty TINYINT NULL,                  -- Số lượng ảnh
    product_weight_g INT NULL,                        -- Trọng lượng (gram)
    product_length_cm TINYINT NULL,                   -- Dài
    product_height_cm TINYINT NULL,                   -- Cao
    product_width_cm TINYINT  NULL,					  -- Rộng
	RowIsCurrent bit  DEFAULT 1 NOT NULL,
    RowStartDate datetime  DEFAULT '12/31/1899' NOT NULL,
    RowEndDate  datetime  DEFAULT '12/31/9999' NOT NULL,
    RowChangeReason nvarchar(200)  DEFAULT '12/31/1899' NULL
);

CREATE TABLE DimSellers (
    sellerKey INT IDENTITY(1,1) PRIMARY KEY,             -- Surrogate Key
    seller_id NVARCHAR(50) NOT NULL,                     -- Mã người bán trong hệ thống
    seller_zip_code_prefix INT NULL,                     -- Mã vùng
    seller_city NVARCHAR(50) NULL,                       -- Thành phố
    seller_state NVARCHAR(50) NOT NULL,                  -- Bang
	RowIsCurrent bit  DEFAULT 1 NOT NULL,
    RowStartDate datetime  DEFAULT '12/31/1899' NOT NULL,
    RowEndDate  datetime  DEFAULT '12/31/9999' NOT NULL,
    RowChangeReason nvarchar(200)  DEFAULT '12/31/1899' NULL
);

CREATE TABLE DimOrders (
    orderKey INT IDENTITY(1,1) PRIMARY KEY,              -- Surrogate Key
    order_id NVARCHAR(50) NOT NULL,                      -- Mã đơn hàng
    customer_id NVARCHAR(50) NOT NULL,                   -- Khách hàng
    order_status NVARCHAR(50) NOT NULL,                  -- Trạng thái đơn hàng
	RowIsCurrent bit  DEFAULT 1 NOT NULL,
    RowStartDate datetime  DEFAULT '12/31/1899' NOT NULL,
    RowEndDate  datetime  DEFAULT '12/31/9999' NOT NULL,
    RowChangeReason nvarchar(200)  DEFAULT '12/31/1899' NULL
);

CREATE TABLE DimOrderItem (
    orderItemKey INT IDENTITY(1,1) PRIMARY KEY,        -- Surrogate Key
    order_id NVARCHAR(50) NOT NULL,                   -- Mã đơn hàng
    order_item_id TINYINT NOT NULL,                   -- STT mặt hàng trong đơn
    product_id NVARCHAR(50) NULL,                     -- Mã sản phẩm
    seller_id NVARCHAR(50) NULL,                      -- Người bán
    shipping_limit_date DATETIME2(7) NULL,            -- Hạn giao hàng
    price FLOAT NULL,                             -- Giá sản phẩm
    freight_value FLOAT NULL,                      -- Phí vận chuyển
	RowIsCurrent bit  DEFAULT 1 NOT NULL,
    RowStartDate datetime  DEFAULT '12/31/1899' NOT NULL,
    RowEndDate  datetime  DEFAULT '12/31/9999' NOT NULL,
    RowChangeReason nvarchar(200)  DEFAULT '12/31/1899' NULL
);

CREATE TABLE DimOrderPayment (
    orderPaymentKey INT IDENTITY(1,1) PRIMARY KEY,     -- Surrogate Key
    order_id NVARCHAR(50) NOT NULL,                   -- Mã đơn hàng
    payment_sequential TINYINT NOT NULL,              -- STT lần thanh toán
    payment_type NVARCHAR(50) NULL,                   -- Loại thanh toán
    payment_installments TINYINT NULL,                -- Số kỳ trả góp
    payment_value FLOAT NOT NULL,                      -- Giá trị thanh toán
	RowIsCurrent bit  DEFAULT 1 NOT NULL,
    RowStartDate datetime  DEFAULT '12/31/1899' NOT NULL,
    RowEndDate  datetime  DEFAULT '12/31/9999' NOT NULL,
    RowChangeReason nvarchar(200)  DEFAULT '12/31/1899' NULL
);

CREATE TABLE DimOrderReview (
    reviewKey INT IDENTITY(1,1) PRIMARY KEY,           -- Surrogate Key
    review_id NVARCHAR(50) NOT NULL,                  -- Mã đánh giá
    order_id NVARCHAR(50) NOT NULL,                   -- Mã đơn hàng
    review_score TINYINT NULL,                        -- Điểm đánh giá (1–5)
    review_comment_title NVARCHAR(50) NULL,           -- Tiêu đề đánh giá
    review_comment_message NVARCHAR(250) NULL,        -- Nội dung đánh giá
	RowIsCurrent bit  DEFAULT 1 NOT NULL,
    RowStartDate datetime  DEFAULT '12/31/1899' NOT NULL,
    RowEndDate  datetime  DEFAULT '12/31/9999' NOT NULL,
    RowChangeReason nvarchar(200)  DEFAULT '12/31/1899' NULL
);

/* DDL for the date dimension */
create table DimDate (
    date_key int not null,
    full_date smalldatetime,
    day_of_week tinyint,
    day_num_in_month tinyint,
    day_num_overall smallint,
    day_name nchar(9),
    day_abbrev varchar(3),
    weekday_flag char(10),
    week_num_in_year tinyint,
    week_num_overall smallint,
    week_begin_date smalldatetime,
    week_begin_date_key int,
    month tinyint,
    month_num_overall smallint,
    month_name nchar(10),
    month_abbrev varchar(10),
    quarter tinyint,
    year smallint,
    yearmo int,
    fiscal_month tinyint,
    fiscal_quarter tinyint,
    fiscal_year smallint,
    last_day_in_month_flag char(30),
    same_day_year_ago_date smalldatetime,
    primary key (date_key))
;

CREATE VIEW vwDimCustomerWithGeo AS
SELECT 
    c.customerKey,
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    g.geolocation_lat,
    g.geolocation_lng,
    g.geolocation_city,
    g.geolocation_state
FROM DimCustomers c
LEFT JOIN DimGeolocation g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;

-- FACT -- 
-- 1. FactSales (Sales Order Analysis)
CREATE TABLE FactSales (
    salesKey INT IDENTITY(1,1) PRIMARY KEY,
    orderKey INT FOREIGN KEY REFERENCES DimOrders(orderkey),
    customerKey INT FOREIGN KEY REFERENCES DimCustomers(customerkey),
    productKey INT FOREIGN KEY REFERENCES DimProducts(productkey),
    sellerKey INT FOREIGN KEY REFERENCES DimSellers(sellerkey),
    dateKey INT FOREIGN KEY REFERENCES DimDate(date_key),
    paymentKey INT FOREIGN KEY REFERENCES DimOrderPayment(orderPaymentKey),
    orderItemKey INT FOREIGN KEY REFERENCES DimOrderItem(orderItemKey),
    price DECIMAL(10,2),
    totalOrderValue DECIMAL(10,2) -- price + freight_value
);

CREATE TABLE FactOrders (
    orderFactKey INT IDENTITY(1,1) PRIMARY KEY,

    -- Foreign Keys
    customerKey INT FOREIGN KEY REFERENCES DimCustomers(customerKey),
    orderKey INT FOREIGN KEY REFERENCES DimOrders(orderKey),
    orderDateKey INT FOREIGN KEY REFERENCES DimDate(date_key),
    approvedDateKey INT FOREIGN KEY REFERENCES DimDate(date_key),
    deliveryDateKey INT FOREIGN KEY REFERENCES DimDate(date_key),
    estimatedDeliveryDateKey INT FOREIGN KEY REFERENCES DimDate(date_key),
    orderPaymentKey INT FOREIGN KEY REFERENCES DimOrderPayment(orderPaymentKey),

    -- Measures
    delivery_time INT,              -- số ngày giao hàng
    order_processing_time INT,      -- số ngày xử lý đơn
    delivery_delay INT,             -- số ngày giao trễ (nếu có)
    order_item_count INT            -- số item trong đơn
);

-- 3. FactReview (Review Analysis)
CREATE TABLE FactReview (
    reviewFactKey INT IDENTITY(1,1) PRIMARY KEY,
    reviewKey INT FOREIGN KEY REFERENCES DimOrderReview(reviewKey),
    customerKey INT FOREIGN KEY REFERENCES DimCustomers(customerKey),
    sellerKey INT FOREIGN KEY REFERENCES DimSellers(sellerKey),
    productKey INT FOREIGN KEY REFERENCES DimProducts(productKey),
    dateKey INT FOREIGN KEY REFERENCES DimDate(date_key),
    orderKey INT FOREIGN KEY REFERENCES DimOrders(orderKey),

    review_score TINYINT,             -- 1–5
    is_negative_review INT,           -- 1 nếu review_score <= 2
    review_comment_length INT,        -- Dài bao nhiêu ký tự
    has_comment INT                   -- 1 nếu có message
);
