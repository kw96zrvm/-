-- ========================================
-- DWS层：数据汇总层
-- 按主题域轻度汇总，提高查询效率
-- ========================================

SET hive.exec.mode.local.auto=true;
SET hive.exec.mode.local.auto.inputbytes.max=50000000;

-- ===== 1. 注册汇总表 =====
DROP TABLE IF EXISTS dws_fact_regiter_sum;
CREATE TABLE dws_fact_regiter_sum(
  regist_date STRING,
  regist_channel STRING,
  channel_name STRING,
  regist_count BIGINT,
  male_count BIGINT,
  female_count BIGINT,
  black_count BIGINT
) COMMENT '注册汇总表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE dws_fact_regiter_sum PARTITION (partition_date)
SELECT
  regist_date,
  regist_channel,
  regist_channel_name,
  COUNT(1) AS regist_count,
  SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS male_count,
  SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS female_count,
  SUM(CASE WHEN is_black_user = 'Y' THEN 1 ELSE 0 END) AS black_count,
  partition_date
FROM dwd_fact_user_regiter_dtl
GROUP BY regist_date, regist_channel, regist_channel_name, partition_date;

-- ===== 2. 申请汇总表 =====
DROP TABLE IF EXISTS dws_fact_loan_apply_sum;
CREATE TABLE dws_fact_loan_apply_sum(
  apply_date STRING,
  product_id BIGINT,
  product_name STRING,
  apply_count BIGINT,
  apply_total_amount DOUBLE,
  apply_avg_amount DOUBLE,
  approve_count BIGINT,
  reject_count BIGINT
) COMMENT '申请汇总表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE dws_fact_loan_apply_sum PARTITION (partition_date)
SELECT
  apply_date,
  product_id,
  product_name,
  COUNT(1) AS apply_count,
  SUM(apply_amount) AS apply_total_amount,
  AVG(apply_amount) AS apply_avg_amount,
  SUM(CASE WHEN status = 'APPROVE' THEN 1 ELSE 0 END) AS approve_count,
  SUM(CASE WHEN status = 'REJECT' THEN 1 ELSE 0 END) AS reject_count,
  partition_date
FROM dwd_fact_loan_apply_dtl
GROUP BY apply_date, product_id, product_name, partition_date;

-- ===== 3. 放款汇总表 =====
DROP TABLE IF EXISTS dws_fact_drawal_sum;
CREATE TABLE dws_fact_drawal_sum(
  lent_date STRING,
  product_id BIGINT,
  product_name STRING,
  lent_count BIGINT,
  lent_total_amt DOUBLE,
  lent_avg_amt DOUBLE,
  com_manager_id BIGINT,
  com_manager_name STRING
) COMMENT '放款汇总表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE dws_fact_drawal_sum PARTITION (partition_date)
SELECT
  lent_date,
  product_id,
  product_name,
  COUNT(1) AS lent_count,
  SUM(lent_amount) AS lent_total_amt,
  AVG(lent_amount) AS lent_avg_amt,
  com_manager_id,
  com_manager_name,
  partition_date
FROM dwd_fact_drawal_dtl
GROUP BY lent_date, product_id, product_name, com_manager_id, com_manager_name, partition_date;

-- ===== 4. 风控审核汇总表 =====
DROP TABLE IF EXISTS dws_fact_loan_credit_sum;
CREATE TABLE dws_fact_loan_credit_sum(
  credit_date STRING,
  credit_result STRING,
  credit_count BIGINT,
  credit_total_amount DOUBLE,
  pass_count BIGINT,
  reject_count BIGINT
) COMMENT '风控审核汇总表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ===== 5. 放款风险汇总表 =====
DROP TABLE IF EXISTS dws_drawal_risk_sum;
CREATE TABLE dws_drawal_risk_sum(
  drawal_id BIGINT,
  user_id BIGINT,
  product_name STRING,
  lent_amount DOUBLE,
  lent_date STRING,
  plan_count INT,
  overdue_count INT,
  max_overdue_day INT,
  unpaid_amount DOUBLE,
  risk_level STRING
) COMMENT '放款风险汇总表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ===== 6. 客户经理汇总表 =====
DROP TABLE IF EXISTS dws_jrxd_com_manager_sum;
CREATE TABLE dws_jrxd_com_manager_sum(
  manager_id BIGINT,
  manager_name STRING,
  deptname STRING,
  apply_count BIGINT,
  apply_total_amt DOUBLE,
  pass_count BIGINT,
  pass_total_amt DOUBLE,
  lent_count BIGINT,
  lent_total_amt DOUBLE,
  stat_date STRING
) COMMENT '客户经理汇总表'
PARTITIONED BY (partition_date STRING COMMENT '分区日期')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;
