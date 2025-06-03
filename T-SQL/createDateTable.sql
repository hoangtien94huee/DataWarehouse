USE olistdb
CREATE TABLE DimDate (
    date_key                       INT           NOT NULL,
    full_date                      SMALLDATETIME NULL,
    day_of_week                    TINYINT       NULL,
    day_num_in_month               TINYINT       NULL,
    day_num_overall                SMALLINT      NULL,
    day_name                       NCHAR(9)      NULL,
    day_abbrev                     NVARCHAR(3)   NULL,  -- was varchar(3)
    weekday_flag                   NVARCHAR(10)  NULL,  -- was char(10)
    week_num_in_year               TINYINT       NULL,
    week_num_overall               SMALLINT      NULL,
    week_begin_date                SMALLDATETIME NULL,
    week_begin_date_key            INT           NULL,
    month                          TINYINT       NULL,
    month_num_overall              SMALLINT      NULL,
    month_name                     NCHAR(10)     NULL,
    month_abbrev                   NVARCHAR(10)  NULL,  -- was varchar(10)
    quarter                        TINYINT       NULL,
    year                           SMALLINT      NULL,
    yearmo                         INT           NULL,
    fiscal_month                   TINYINT       NULL,
    fiscal_quarter                 TINYINT       NULL,
    fiscal_year                    SMALLINT      NULL,
    last_day_in_month_flag         NVARCHAR(30)  NULL,  -- was char(30)
    same_day_year_ago_date         SMALLDATETIME NULL,
    PRIMARY KEY (date_key)
);