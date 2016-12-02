#!/bin/bash 
#this script is write by haoli on Aug. 31th ,2016
databases_zabbix=$(mysql -uzabbix -pzabbix -e "show databases;use information_schema;select concat(round(sum(DATA_LENGTH/1024/1024),2),'MB') as data from TABLES where table_schema='zabbix';" )
echo "              " >> zabbix-database-size.txt
echo $(date)":" >> zabbix-database-size.txt
echo $databases_zabbix  | awk '{print $4}' >> zabbix-database-size.txt
