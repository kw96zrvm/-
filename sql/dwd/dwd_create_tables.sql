-- ========================================
-- DWD层：事实表明细数据
-- 围绕业务过程：注册、申请、审核、放款、还款
-- ========================================

-- 设置本地模式（小数据量优化）
SET hive.exec.mode.local.auto=true;
SET hive.exec.mode.local.auto.inputbytes.max=50000000;
SET hive.exec.mode.local.auto.input.files.max=10;

-- ===== 1. 用户注册事实表 =====
DROP TABLE IF EXISTS dwd_fact_user_regiter_dtl;
CREATE TABLE dwd_fact_user_regiter_dtl(
  user_id BIGINT,
  phone STRING,
  real_name STRING,
  gender STRING,
  birthday STRING,
  age INT,
  is_marry STRING,
  degree_type STRING,
  province STRING,
  city STRING,
  regist_channel STRING,
  regist_channel_name STRING,
  is_black_user STRING,
  ethical_level STRING,
  credit_level STRING,
  regist_date STRING,
  regist_time STRING
) COMMENT '用户注册明细事实表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 导入用户注册数据
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE dwd_fact_user_regiter_dtl PARTITION (partition_date)
SELECT
  u.id AS user_id,
  u.phone,
  u.real_name,
  u.gender,
  u.birthday,
  floor(datediff(from_unixtime(unix_timestamp(), 'yyyy-MM-dd'), u.birthday) / 365) AS age,
  u.is_marry,
  u.degree_type,
  u.province,
  u.city,
  u.regist_channel,
  c.name AS regist_channel_name,
  u.is_black_user,
  u.ethical_level,
  u.credit_level,
  to_date(u.created_at) AS regist_date,
  u.created_at AS regist_time,
  regexp_replace(to_date(u.created_at), '-', '') AS partition_date
FROM ods_jrxd_users u
LEFT JOIN ods_jrxd_channel_info c ON u.regist_channel = c.channel_code;

-- ===== 2. 贷款申请事实表 =====
DROP TABLE IF EXISTS dwd_fact_loan_apply_dtl;
CREATE TABLE dwd_fact_loan_apply_dtl(
  apply_id BIGINT,
  user_id BIGINT,
  product_id BIGINT,
  product_name STRING,
  apply_amount DOUBLE,
  apply_term INT,
  apply_date STRING,
  status STRING,
  channel_id BIGINT,
  channel_name STRING,
  com_manager_id BIGINT,
  com_manager_name STRING
) COMMENT '贷款申请明细事实表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE dwd_fact_loan_apply_dtl PARTITION (partition_date)
SELECT
  a.id AS apply_id,
  a.user_id,
  a.product_id,
  p.product_name,
  a.apply_amount,
  a.apply_term,
  to_date(a.apply_date) AS apply_date,
  a.status,
  a.channel_id,
  c.name AS channel_name,
  a.com_manager_id,
  m.name AS com_manager_name,
  regexp_replace(to_date(a.created_at), '-', '') AS partition_date
FROM ods_jrxd_loan_apply a
LEFT JOIN ods_jrxd_dict_product p ON a.product_id = p.id
LEFT JOIN ods_jrxd_channel_info c ON a.channel_id = c.id
LEFT JOIN ods_jrxd_com_manager_info m ON a.com_manager_id = m.id;

-- ===== 3. 风控审核事实表 =====
DROP TABLE IF EXISTS dwd_fact_credit_dtl;
CREATE TABLE dwd_fact_credit_dtl(
  credit_id BIGINT,
  apply_id BIGINT,
  user_id BIGINT,
  credit_type STRING,
  credit_result STRING,
  credit_score INT,
  credit_amount DOUBLE,
  credit_date STRING,
  auditor_id BIGINT,
  auditor_name STRING,
  auditor_opinion STRING,
  status STRING,
  apply_amount DOUBLE,
  product_name STRING
) COMMENT '风控审核明细事实表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE dwd_fact_credit_dtl PARTITION (partition_date)
SELECT
  lc.id AS credit_id,
  lc.apply_id,
  lc.user_id,
  lc.credit_type,
  lc.credit_result,
  lc.credit_score,
  lc.credit_amount,
  lc.credit_date,
  lc.auditor_id,
  lc.auditor_name,
  lc.auditor_opinion,
  lc.status,
  la.apply_amount,
  p.product_name,
  regexp_replace(to_date(lc.created_at), '-', '') AS partition_date
FROM ods_jrxd_loan_credit lc
LEFT JOIN ods_jrxd_loan_apply la ON lc.apply_id = la.id
LEFT JOIN ods_jrxd_dict_product p ON la.product_id = p.id;

-- ===== 4. 放款事实表 =====
DROP TABLE IF EXISTS dwd_fact_drawal_dtl;
CREATE TABLE dwd_fact_drawal_dtl(
  drawal_id BIGINT,
  user_id BIGINT,
  product_id BIGINT,
  product_name STRING,
  apply_amount DOUBLE,
  apply_term INT,
  apply_date STRING,
  status STRING,
  com_manager_id BIGINT,
  com_manager_name STRING,
  lent_amount DOUBLE,
  lent_date STRING,
  interest_rate DOUBLE
) COMMENT '放款明细事实表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE dwd_fact_drawal_dtl PARTITION (partition_date)
SELECT
  d.id AS drawal_id,
  d.user_id,
  d.product_id,
  p.product_name,
  d.apply_amount,
  d.apply_term,
  to_date(d.apply_date) AS apply_date,
  d.status,
  d.com_manager_id,
  m.name AS com_manager_name,
  d.apply_amount AS lent_amount,
  to_date(d.created_at) AS lent_date,
  p.interest_rate,
  regexp_replace(to_date(d.created_at), '-', '') AS partition_date
FROM ods_jrxd_drawal_apply d
LEFT JOIN ods_jrxd_dict_product p ON d.product_id = p.id
LEFT JOIN ods_jrxd_com_manager_info m ON d.com_manager_id = m.id;

-- ===== 5. 还款事实表 =====
DROP TABLE IF EXISTS dwd_fact_repay_play_dtl;
CREATE TABLE dwd_fact_repay_play_dtl(
  plan_id BIGINT,
  user_id BIGINT,
  drawal_id BIGINT,
  plan_term INT,
  plan_date STRING,
  plan_amount DOUBLE,
  plan_principal DOUBLE,
  plan_interest DOUBLE,
  status STRING,
  actual_date STRING,
  actual_amount DOUBLE,
  overdue_day INT,
  overdue_amount DOUBLE,
  is_overdue STRING
) COMMENT '还款明细事实表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE dwd_fact_repay_play_dtl PARTITION (partition_date)
SELECT
  rp.id AS plan_id,
  rp.user_id,
  rp.drawal_id,
  rp.plan_term,
  rp.plan_date,
  rp.plan_amount,
  rp.plan_principal,
  rp.plan_interest,
  rp.status,
  rp.actual_date,
  rp.actual_amount,
  rp.overdue_day,
  rp.overdue_amount,
  CASE WHEN rp.overdue_day > 0 THEN 'Y' ELSE 'N' END AS is_overdue,
  regexp_replace(to_date(rp.created_at), '-', '') AS partition_date
FROM ods_jrxd_repay_plan rp;
