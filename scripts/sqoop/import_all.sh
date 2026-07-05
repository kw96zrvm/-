#!/bin/bash
# Sqoop 全量导入: MySQL -> Hive ODS层

HIVE_DB=finance

while read table_name
do
    echo "开始导入表: "

    sqoop import \
      --connect 'jdbc:mysql://shucang:3306/jrxd?zeroDateTimeBehavior=convertToNull' \
      --driver com.mysql.cj.jdbc.Driver \
      --username root \
      --password 123456 \
      --table  \
      --hive-import \
      --hive-overwrite \
      --hive-table ods_jrxd_ \
      --hive-database  \
      -m 1

    if [ True -eq 0 ]; then
        echo "表  导入成功"
    else
        echo "表  导入失败"
    fi
done < tables.txt

echo "全部导入完成"
