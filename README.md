# 互联网金融信贷数仓项目

## 项目概述
基于互联网信贷业务数据，搭建离线数据仓库，覆盖用户管理、风控审核、放款、还款、逾期等核心环节，实现从数据采集到可视化展示的全流程建设。

## 技术栈
| 组件 | 用途 |
|------|------|
| Hadoop HDFS | 分布式存储 |
| Hive | 数据仓库存储与计算 |
| Sqoop | MySQL -> Hive 数据同步 |
| DataX | Hive -> MySQL 数据导出 |
| DolphinScheduler | 任务编排与调度 |
| DataGear | BI 可视化看板 |

## 数仓架构

\MySQL业务库
    |
    | Sqoop
    v
ODS层 (原始数据)
    |
    | HiveSQL
    v
DIM层 (维度表)          DWD层 (事实表明细)
    |                         |
    +----------+--------------+
               |
               v
          DWS层 (轻度汇总)
               |
               | HiveSQL
               v
          ADS层 (业务指标)
               |
               | DataX
               v
          MySQL (jrxd_bi)
               |
               | DataGear
               v
          BI可视化看板
\
## 分层说明
- **ODS层**: 从MySQL业务库同步的原始数据，保持与源表一致
- **DIM层**: 维度表，如用户、产品、渠道、客户经理、时间、地区
- **DWD层**: 事实表明细数据，围绕业务过程设计（注册、申请、审核、放款、还款）
- **DWS层**: 按主题轻度汇总，提高查询效率
- **ADS层**: 业务指标层，直接输出给BI系统

## 业务主题域
- 用户主题域: 用户注册、用户画像
- 经营主题域: 信贷申请、审核、放款
- 风险主题域: 风控审核、逾期分析
- 财务主题域: 还款、利息、业绩统计

## 项目结构

\finance_dw_project/
├── sql/                     # HiveSQL脚本
│   ├── 00_create_database.sql    # 建库
│   ├── ods/                      # ODS层
│   │   └── ods_create_tables.sql
│   ├── dim/                      # 维度层
│   │   └── dim_create_tables.sql
│   ├── dwd/                      # 明细层
│   │   └── dwd_create_tables.sql
│   ├── dws/                      # 汇总层
│   │   └── dws_create_tables.sql
│   └── ads/                      # 应用层
│       └── ads_create_tables.sql
├── scripts/                 # 执行脚本
│   ├── sqoop/                    # Sqoop同步脚本
│   │   ├── import_all.sh              # 全量导入ODS
│   │   └── tables.txt                # 表名列表
└── README.md
## 业务表说明
从MySQL业务库(jrxd)同步19张业务表到ODS层:
- 用户相关: users, user_det, user_md5, user_ocrlog, user_quota
- 产品相关: dict_product
- 渠道相关: channel_info
- 员工相关: com_manager_info
- 申请相关: loan_apply, loan_apply_credit_report, loan_apply_salary
- 风控相关: loan_credit
- 放款相关: drawal_apply, drawal_address, drawal_companys
- 还款相关: repay_plan, repay_plan_item, repay_plan_item_his
- 地理相关: dict_provinces, dict_citys

## 核心ADS指标
- 注册量统计: 按年龄、时间统计用户注册数
- 申请统计: 申请单数、申请金额
- 放款统计: 放款金额、放款笔数
- 还款统计: 还款金额、还款率、不良率
- 客户经理业绩: 放款金额、审批通过率
