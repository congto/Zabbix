#!/bin/bash 
#author by lihao
#------------------install zabbix packages----------------------- 

# ansi colors for formatting heredoc
ESC=$(printf "\e")
GREEN="$ESC[0;32m"
NO_COLOR="$ESC[0;0m"
RED="$ESC[0;31m"
MAGENTA="$ESC[0;35m"
YELLOW="$ESC[0;33m"
BLUE="$ESC[0;34m"
WHITE="$ESC[0;37m"
#PURPLE="$ESC[0;35m"
CYAN="$ESC[0;36m"

       yum clean all 1>/dev/null 2>&1 
       yum install zabbix-server-mysql -y  1>/dev/null 2>&1 &&
echo -e "\e[1;36m zabbix-server-mysql installed \e[0m" 
       yum install zabbix-web-mysql -y     1>/dev/null 2>&1  &&
echo -e "\e[1;36m zabbix-web-mysql installed \e[0m"
       yum install mariadb-server -y    1>/dev/null 2>&1  &&
echo -e "\e[1;36m mariadb-server installed \e[0m"
       yum install zabbix-agent -y     1>/dev/null 2>&1 &&
echo -e "\e[1;36m zabbix-agent installed \e[0m"

       yum install zabbix-get -y   1>/dev/null 2>&1 &&
echo -e "\e[1;36m zabbix-get installed \e[0m"
systemctl enable mariadb  1>/dev/null 2>&1
systemctl start mariadb 

#-----------------Create zabbix database and create zabbix user-----------------
mysqladmin -uroot password admin && 
mysql -uroot -padmin -e "create database zabbix character set utf8;grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';flush privileges;" &&
echo -e " \e[1;36m --->All pacakge of zabbix has been installed, Begin to import data to zabbix database ...   \e[0m "

#------------------import zabbix database data to mysql DB
zcat   /usr/share/doc/zabbix-server-mysql-$(rpm -qa | grep zabbix-web-mysql | awk -F "-" '{print $4}')/create.sql.gz | mysql -uzabbix  -pzabbix zabbix  &&
echo -e "\e[1;36m ----->Import Zabbix Data Success \e[0m"

#----------------configure the zabbix_server.conf--------------------------
sed -i '108 i DBPassword=zabbix' /etc/zabbix/zabbix_server.conf &&
sed -i 's/AlertScriptsPath=\/usr\/lib\/zabbix\/alertscripts/AlertScriptsPath=\/etc\/zabbix\/scripts/' /etc/zabbix/zabbix_server.conf && 

#---------------copy script ---------------
mkdir -p /etc/zabbix/scripts &&
cp ./scripts/Email.py /etc/zabbix/scripts 
cp ./scripts/Wechat.py /etc/zabbix/scripts 
cp ./scripts/get-zabbix-database-size.sh /etc/zabbix/scripts 
cp ./scripts/zabbix.conf.php /etc/zabbix/web  
chown -R zabbix:zabbix /etc/zabbix/scripts
chmod 700 /etc/zabbix/scripts/*
echo -e "\e[1;36m ----->/etc/zabbix/zabbix_server.conf edited finished \e[0m"
echo -e "\e[1;36m ----->Email.py and Wechat.py has been copy to /etc/zabbix/scripts \e[0m"
#----------------Setup the timezone of zabbix server -------------
sed -i '19 i php_value date.timezone Asia/Shanghai ' /etc/httpd/conf.d/zabbix.conf && 

#----------------disable selinux-------------------------
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config #disable selinux in conf file 
setenforce 0  &&
echo -e "\e[1;36m ----->The Selinux Status: $( getenforce) \e[0m"
systemctl enable  httpd 1>/dev/null 2>&1
systemctl start httpd  &&
echo -e "\e[1;36m ----->The httpd daemon is running \e[0m"

#---------------add get zabbix database size script----------
sed -i '294 i  UserParameter=get-zabbix-database-size,/etc/zabbix/scripts/get-zabbix-database-size.sh $1 ' /etc/zabbix/zabbix_agentd.conf &&
systemctl enable zabbix-agent 1>/dev/null 2>&1
systemctl start zabbix-agent &&
echo -e "\e[1;36m ----->The zabbix-agent daemon is running \e[0m"

systemctl enable zabbix-server 1>/dev/null 2>&1
systemctl start zabbix-server &&
echo -e "\e[1;36m ----->Zabbix Server Daemon Has Been Runing \e[0m"  

