#!/bin/sh
#author by haoli on 13th Oct of 2016
#wget -r -p -np -k -P ./ http://110.76.187.145/repos/
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

README=$(cat ./README.txt)
OS=$(cat /etc/redhat-release | awk '{print $1}')
if [ $OS = Red ];then
OSVERSION=$(cat /etc/redhat-release | awk '{print $7}' | awk -F "." '{print $2}')
else
OSVERSION=$(cat /etc/redhat-release | awk '{print $4}' | awk -F "." '{print $2}')
fi

echo -e "\e[1;33m $README \e[0m"

function install(){
#echo -e " \033[1m Begin install zabbix server  ..."
echo -e "\e[1;36m Begin install zabbix server  ... \e[0m"
#mkdir /etc/yum.repos.d/bak
#mv /etc/yum.repos.d/*  /etc/yum.repos.d/bak/  1>/dev/null 2>&1 
rm -rf /etc/yum.repos.d/* 
echo -e "\e[1;33m Please choose which version of zabbix-server you want to install (Note:you can only choose 3.0 or 3.2 to install. 3.0 is LTS Version ,3.2 is latest version ): \e[0m"

#--------------------this functin is setup the yum repo, you can change the repo on ./repo dir
function choiceversion(){
      case $1 in
       3.2)
       cp ./repo/*  /etc/yum.repos.d/
       rpm -ivh http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm  1>/dev/null 2>&1
       ;; 
       3.0)
       cp ./repo/*  /etc/yum.repos.d/
       #cp ./repo/zabbix3.0.repo   /etc/yum.repos.d/
       esac 
     }
read VERSION
choiceversion $VERSION
echo -e "\e[1;36m setup zabbix repos successfull \e[0m"

#------------------execute the install script --------
source ./modularization/install.sh 
source ./modularization/firewall.sh
echo -e "\e[1;32m ----->Please Go Ahead Zabbix frontend to finished install zabbix server \e[0m"
echo -e "\e[1;32m ----->PLEASE Login as Admin/zabbix in IP/zabbix by your Browser \e[0m"
}

function choice(){
          case $1 in
          1)
          #--------------Downgrade the pacakge of systemc, since the higher version cause can't start zabbix-server daemon
          rpm -Uvh --force ./pacakges/gnutls-3.1.18-8.el7.x86_64.rpm   1>/dev/null 2>&1 
          install
          ;;
          2)
          echo "This script will be deploy zabbix-server on $GREEN $(cat /etc/redhat-release) $NO_CLOLOR"
          install
          ;;
          3)
          echo "This script will be deploy zabbix-server on $GREEN $(cat /etc/redhat-release) $NO_CLOLOR"
          install
          exit 0
          esac
}

if [ $(rpm -qa | grep zabbix | wc -l) -ge 1 ];then
source ./modularization/clean.sh
choice $OSVERSION
else
choice $OSVERSION
fi
