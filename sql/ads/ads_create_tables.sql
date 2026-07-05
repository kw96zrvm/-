-- ========================================
-- ADS层：业务指标层
-- 直接输出给BI系统
-- ========================================

-- ===== 1. 注册量统计 =====
DROP TABLE IF EXISTS ads_register_cnt;
CREATE TABLE ads_register_cnt(
  regist_date STRING,
  channel_name STRING,
  regist_count BIGINT,
  male_count BIGINT,
  female_count BIGINT
) COMMENT '注册量统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE ads_register_cnt
SELECT
  regist_date,
  channel_name,
  SUM(regist_count) AS regist_count,
  SUM(male_count) AS male_count,
  SUM(female_count) AS female_count
FROM dws_fact_regiter_sum
GROUP BY regist_date, channel_name;

-- ===== 2. 年龄段注册统计 =====
DROP TABLE IF EXISTS ads_age_range_regist;
CREATE TABLE ads_age_range_regist(
  age_range STRING,
  user_count BIGINT
) COMMENT '年龄段注册统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE ads_age_range_regist
SELECT
  CASE WHEN age < 20 THEN '20以下'
       WHEN age >= 20 AND age < 30 THEN '20-30岁'
       WHEN age >= 30 AND age < 40 THEN '30-40岁'
       WHEN age >= 40 AND age < 50 THEN '40-50岁'
       ELSE '50岁以上'
  END AS age_range,
  COUNT(1) AS user_count
FROM dim_jrxd_user
GROUP BY CASE WHEN age < 20 THEN '20以下'
              WHEN age >= 20 AND age < 30 THEN '20-30岁'
              WHEN age >= 30 AND age < 40 THEN '30-40岁'
              WHEN age >= 40 AND age < 50 THEN '40-50岁'
              ELSE '50岁以上' END;

-- ===== 3. 申请统计 =====
DROP TABLE IF EXISTS ads_apply_sum;
CREATE TABLE ads_apply_sum(
  apply_date STRING,
  product_name STRING,
  apply_count BIGINT,
  apply_total_amount DOUBLE,
  apply_avg_amount DOUBLE
) COMMENT '申请统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE ads_apply_sum
SELECT
  apply_date,
  product_name,
  SUM(apply_count) AS apply_count,
  SUM(apply_total_amount) AS apply_total_amount,
  AVG(apply_avg_amount) AS apply_avg_amount
FROM dws_fact_loan_apply_sum
GROUP BY apply_date, product_name;

-- ===== 4. 申请单数统计（按状态） =====
DROP TABLE IF EXISTS ads_apply_num;
CREATE TABLE ads_apply_num(
  status STRING,
  apply_num BIGINT
) COMMENT '申请单数统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ===== 5. 放款统计 =====
DROP TABLE IF EXISTS ads_fact_drawal_sum;
CREATE TABLE ads_fact_drawal_sum(
  data_date STRING,
  lent_count BIGINT,
  lent_amt DOUBLE,
  lent_user_count BIGINT
) COMMENT '放款统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE ads_fact_drawal_sum
SELECT
  lent_date AS data_date,
  SUM(lent_count) AS lent_count,
  SUM(lent_total_amt) AS lent_amt,
  COUNT(DISTINCT com_manager_id) AS lent_user_count
FROM dws_fact_drawal_sum
GROUP BY lent_date;

-- ===== 6. 放款汇总（按产品） =====
DROP TABLE IF EXISTS ads_lent_summary;
CREATE TABLE ads_lent_summary(
  product_name STRING,
  lent_count BIGINT,
  lent_total_amt DOUBLE,
  lent_avg_amt DOUBLE,
  max_amt DOUBLE,
  min_amt DOUBLE
) COMMENT '放款汇总(按产品)'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ===== 7. 信贷审核统计 =====
DROP TABLE IF EXISTS ads_loan_credit_sum;
CREATE TABLE ads_loan_credit_sum(
  manager_id BIGINT,
  dateid STRING,
  zs_pass_num BIGINT,
  zs_pass_amt DOUBLE
) COMMENT '信贷审核统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ===== 8. 还款统计 =====
DROP TABLE IF EXISTS ads_repay_sum;
CREATE TABLE ads_repay_sum(
  amount_range STRING,
  user_num INT
) COMMENT '还款金额区间统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ===== 9. 不良率统计 =====
DROP TABLE IF EXISTS ads_repay_sum_bl;
CREATE TABLE ads_repay_sum_bl(
  qs STRING,
  drawal_cnt INT,
  users_num INT,
  bl DOUBLE
) COMMENT '不良率统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ===== 10. 逾期区间人数统计 =====
DROP TABLE IF EXISTS ads_unpaid_range_person;
CREATE TABLE ads_unpaid_range_person(
  overdue_range STRING,
  user_count BIGINT
) COMMENT '逾期区间人数统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ===== 11. 客户经理月度统计 =====
DROP TABLE IF EXISTS ads_jrxd_com_manager_sum;
CREATE TABLE ads_jrxd_com_manager_sum(
  manager_id BIGINT,
  manager_name STRING,
  deptname STRING,
  apply_count BIGINT,
  lent_total_amt DOUBLE,
  stat_month STRING
) COMMENT '客户经理月度统计'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- ===== 12. 客户经理年龄分布 =====
DROP TABLE IF EXISTS ads_jrxd_com_manager_age_range;
CREATE TABLE ads_jrxd_com_manager_age_range(
  age_range STRING,
  manager_count BIGINT
) COMMENT '客户经理年龄分布'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;
