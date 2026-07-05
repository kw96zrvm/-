-- ========================================
-- DIM层：维度表
-- 包括：用户、产品、渠道、客户经理、时间、地区维度
-- ========================================

-- ===== 1. 时间维度表 =====
DROP TABLE IF EXISTS dim_jrxd_calendar;
CREATE TABLE dim_jrxd_calendar(
  dateid STRING COMMENT '日期ID yyyyMMdd',
  date_desc STRING COMMENT '日期描述',
  day_of_month INT COMMENT '当月第几天',
  day_of_month_desc STRING COMMENT '当月第几天描述',
  day_of_year INT COMMENT '当年第几天',
  day_of_year_desc STRING COMMENT '当年第几天描述',
  week_of_year INT COMMENT '当年第几周',
  week_of_year_desc STRING COMMENT '当年第几周描述',
  month_of_year INT COMMENT '月份',
  month_of_year_desc STRING COMMENT '月份描述',
  monthid STRING COMMENT '月份ID yyyyMM',
  month_desc STRING COMMENT '月份描述',
  yearid INT COMMENT '年份ID',
  year_desc STRING COMMENT '年份描述',
  quarterid STRING COMMENT '季度ID yyyy01/02/03/04',
  quarter_desc STRING COMMENT '季度描述 yyyyQ1/Q2/Q3/Q4',
  quarter_of_year INT COMMENT '第几季度1-4',
  quarter_of_year_desc STRING COMMENT '第几季度描述'
) COMMENT '时间维度表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 生成时间维度数据（2019-2020年）
INSERT OVERWRITE TABLE dim_jrxd_calendar
WITH a AS (
  SELECT posexplode(split(repeat('o', datediff('2020-12-31', '2019-01-01')), 'o'))
)
SELECT
  date_format(date_add('2019-01-01', pos), 'yyyyMMdd') AS dateid,
  date_add('2019-01-01', pos) AS date_desc,
  day(date_add('2019-01-01', pos)) AS day_of_month,
  concat(year(date_add('2019-01-01', pos)), '年', month(date_add('2019-01-01', pos)), '月第', day(date_add('2019-01-01', pos)), '天') AS day_of_month_desc,
  datediff(date_add('2019-01-01', pos), concat(year(date_add('2019-01-01', pos)), '-01-01')) + 1 AS day_of_year,
  concat(year(date_add('2019-01-01', pos)), '年第', datediff(date_add('2019-01-01', pos), concat(year(date_add('2019-01-01', pos)), '-01-01')) + 1, '天') AS day_of_year_desc,
  weekofyear(date_add('2019-01-01', pos)) AS week_of_year,
  concat(year(date_add('2019-01-01', pos)), '年第', weekofyear(date_add('2019-01-01', pos)), '周') AS week_of_year_desc,
  month(date_add('2019-01-01', pos)) AS month_of_year,
  concat(year(date_add('2019-01-01', pos)), '年', month(date_add('2019-01-01', pos)), '月') AS month_of_year_desc,
  date_format(date_add('2019-01-01', pos), 'yyyyMM') AS monthid,
  date_format(date_add('2019-01-01', pos), 'yyyyMM') AS month_desc,
  year(date_add('2019-01-01', pos)) AS yearid,
  concat(year(date_add('2019-01-01', pos)), '年') AS year_desc,
  CASE WHEN month(date_add('2019-01-01', pos)) IN (1,2,3) THEN concat(year(date_add('2019-01-01', pos)), '01')
       WHEN month(date_add('2019-01-01', pos)) IN (4,5,6) THEN concat(year(date_add('2019-01-01', pos)), '02')
       WHEN month(date_add('2019-01-01', pos)) IN (7,8,9) THEN concat(year(date_add('2019-01-01', pos)), '03')
       WHEN month(date_add('2019-01-01', pos)) IN (10,11,12) THEN concat(year(date_add('2019-01-01', pos)), '04')
  END AS quarterid,
  CASE WHEN month(date_add('2019-01-01', pos)) IN (1,2,3) THEN concat(year(date_add('2019-01-01', pos)), 'Q1')
       WHEN month(date_add('2019-01-01', pos)) IN (4,5,6) THEN concat(year(date_add('2019-01-01', pos)), 'Q2')
       WHEN month(date_add('2019-01-01', pos)) IN (7,8,9) THEN concat(year(date_add('2019-01-01', pos)), 'Q3')
       WHEN month(date_add('2019-01-01', pos)) IN (10,11,12) THEN concat(year(date_add('2019-01-01', pos)), 'Q4')
  END AS quarter_desc,
  CASE WHEN month(date_add('2019-01-01', pos)) IN (1,2,3) THEN 1
       WHEN month(date_add('2019-01-01', pos)) IN (4,5,6) THEN 2
       WHEN month(date_add('2019-01-01', pos)) IN (7,8,9) THEN 3
       WHEN month(date_add('2019-01-01', pos)) IN (10,11,12) THEN 4
  END AS quarter_of_year,
  CASE WHEN month(date_add('2019-01-01', pos)) IN (1,2,3) THEN concat(year(date_add('2019-01-01', pos)), '年1季度')
       WHEN month(date_add('2019-01-01', pos)) IN (4,5,6) THEN concat(year(date_add('2019-01-01', pos)), '年2季度')
       WHEN month(date_add('2019-01-01', pos)) IN (7,8,9) THEN concat(year(date_add('2019-01-01', pos)), '年3季度')
       WHEN month(date_add('2019-01-01', pos)) IN (10,11,12) THEN concat(year(date_add('2019-01-01', pos)), '年4季度')
  END AS quarter_of_year_desc
FROM a;

-- ===== 2. 渠道维度表 =====
DROP TABLE IF EXISTS dim_jrxd_channel;
CREATE TABLE dim_jrxd_channel(
  id BIGINT,
  name STRING,
  channel_code STRING,
  channel_type STRING,
  channel_cus_fee STRING,
  channel_perf_fee STRING,
  created_at STRING,
  updated_at STRING,
  etl_time STRING
) COMMENT '渠道维度表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- ===== 3. 客户经理维度表 =====
DROP TABLE IF EXISTS dim_jrxd_com_manager;
CREATE TABLE dim_jrxd_com_manager(
  id BIGINT,
  name STRING,
  birthday STRING,
  sex STRING,
  entry_date STRING,
  con_emp_no STRING,
  is_positive STRING,
  deptname STRING,
  bank_card STRING,
  departure_date STRING,
  updated_at STRING,
  created_at STRING,
  etl_time STRING
) COMMENT '客户经理维度表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- ===== 4. 用户维度表 =====
DROP TABLE IF EXISTS dim_jrxd_user;
CREATE TABLE dim_jrxd_user(
  user_id BIGINT,
  phone STRING,
  real_name STRING,
  id_card_no STRING,
  gender STRING,
  birthday STRING,
  age INT,
  age_range STRING,
  is_marry STRING,
  degree_type STRING,
  province STRING,
  city STRING,
  district STRING,
  regist_channel STRING,
  is_black_user STRING,
  ethical_level STRING,
  comprehensive_level STRING,
  credit_level STRING,
  created_at STRING,
  etl_time STRING
) COMMENT '用户维度表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- ===== 5. 产品维度表 =====
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product(
  id BIGINT,
  product_code STRING,
  product_name STRING,
  product_type STRING,
  product_kind STRING,
  loan_min_amount DOUBLE,
  loan_max_amount DOUBLE,
  loan_min_term INT,
  loan_max_term INT,
  interest_rate DOUBLE,
  status STRING,
  created_at STRING,
  updated_at STRING,
  etl_time STRING
) COMMENT '产品维度表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- ===== 6. 地区维度表 =====
DROP TABLE IF EXISTS dim_region;
CREATE TABLE dim_region(
  province_code STRING,
  province_name STRING,
  city_code STRING,
  city_name STRING
) COMMENT '地区维度表'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
