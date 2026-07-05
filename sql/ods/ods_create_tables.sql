-- ========================================
-- ODS层：从MySQL业务库同步的原始数据
-- 命名规范：ods_jrxd_{mysql_table_name}
-- 导入方式：Sqoop全量导入（保留最新一天数据）
-- ========================================

-- 用户表
CREATE TABLE IF NOT EXISTS ods_jrxd_users(
  id BIGINT,
  phone STRING,
  hash_email STRING,
  login_pwd STRING,
  pay_pwd STRING,
  real_name STRING,
  id_card_no STRING,
  id_card_type STRING,
  id_card_validity STRING,
  birthday STRING,
  gender STRING,
  is_marry STRING,
  degree_type STRING,
  nationality STRING,
  province STRING,
  city STRING,
  district STRING,
  address STRING,
  is_face_valid STRING,
  face_valid_time STRING,
  is_risk_user STRING,
  risk_type STRING,
  ethical_level STRING,
  comprehensive_level STRING,
  credit_level STRING,
  consumption_level STRING,
  behavior_level STRING,
  is_black_user STRING,
  black_type STRING,
  regist_channel STRING,
  recommend_code STRING,
  invite_times BIGINT,
  say_words STRING,
  is_old_user STRING,
  created_at STRING,
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 用户详情表
CREATE TABLE IF NOT EXISTS ods_jrxd_user_det(
  id BIGINT,
  user_id BIGINT,
  annual_income STRING,
  monthly_salary STRING,
  work_company STRING,
  work_industry STRING,
  work_position STRING,
  work_start_date STRING,
  city_id BIGINT,
  car_type STRING,
  house_type STRING,
  has_social_security STRING,
  has_accumulation_fund STRING,
  social_security_base STRING,
  accumulation_fund_base STRING,
  contact_name STRING,
  contact_relation STRING,
  contact_phone STRING,
  other_contact_name STRING,
  other_contact_relation STRING,
  other_contact_phone STRING,
  created_at STRING,
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 用户额度表
CREATE TABLE IF NOT EXISTS ods_jrxd_user_quota(
  id BIGINT,
  user_id BIGINT,
  product_id BIGINT,
  status STRING,
  total_quota DOUBLE,
  used_quota DOUBLE,
  remain_quota DOUBLE,
  start_time STRING,
  end_time STRING,
  loan_count INT,
  created_at STRING,
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 渠道信息表
CREATE TABLE IF NOT EXISTS ods_jrxd_channel_info(
  id BIGINT,
  name STRING,
  channel_code STRING,
  channel_type STRING,
  channel_cus_fee STRING,
  channel_perf_fee STRING,
  created_at STRING,
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 客户经理表
CREATE TABLE IF NOT EXISTS ods_jrxd_com_manager_info(
  id BIGINT,
  name STRING,
  birthday STRING,
  sex STRING,
  phone STRING,
  email STRING,
  entry_date STRING,
  con_emp_no STRING,
  is_positive STRING,
  deptname STRING,
  bank_card STRING,
  departure_date STRING,
  created_at STRING,
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 产品字典表
CREATE TABLE IF NOT EXISTS ods_jrxd_dict_product(
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
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 贷款申请表
CREATE TABLE IF NOT EXISTS ods_jrxd_loan_apply(
  id BIGINT,
  user_id BIGINT,
  product_id BIGINT,
  apply_amount DOUBLE,
  apply_term INT,
  apply_date STRING,
  apply_time STRING,
  status STRING,
  channel_id BIGINT,
  com_manager_id BIGINT,
  created_at STRING,
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 风控审核表
CREATE TABLE IF NOT EXISTS ods_jrxd_loan_credit(
  id BIGINT,
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
  created_at STRING,
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 放款申请表
CREATE TABLE IF NOT EXISTS ods_jrxd_drawal_apply(
  id BIGINT,
  user_id BIGINT,
  product_id BIGINT,
  apply_amount DOUBLE,
  apply_term INT,
  apply_date STRING,
  status STRING,
  loan_credit_id BIGINT,
  com_manager_id BIGINT,
  created_at STRING,
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 还款计划表
CREATE TABLE IF NOT EXISTS ods_jrxd_repay_plan(
  id BIGINT,
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
  created_at STRING,
  updated_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 省份字典表
CREATE TABLE IF NOT EXISTS ods_jrxd_dict_provinces(
  id BIGINT,
  province_code STRING,
  province_name STRING,
  created_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 城市字典表
CREATE TABLE IF NOT EXISTS ods_jrxd_dict_citys(
  id BIGINT,
  city_code STRING,
  city_name STRING,
  province_code STRING,
  created_at STRING
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
