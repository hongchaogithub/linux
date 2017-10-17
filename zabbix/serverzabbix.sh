#!/bin/bash
#此脚本在zabbix server上执行，为主脚本，其他主机皆由此脚本自动复制各自脚本并执行
#关闭防火墙
setenforce 0
iptables -F

#设置时区和更新时间
timedatectl set-timezone Asia/Shanghai
ntpdate -u 172.25.254.254

#安装lftp软件并下载zabbix
sh yum_shell.sh lftp gcc gcc-c++ mariadb-devel libxml2-devel net-snmp-devel libcurl-devel expect

yuanlujing=`pwd`
#lftp 172.25.254.250:/notes/project/software/zabbix << end
#mirror zabbix3.2/
#exit
#end

#解压、编译、安装
cd mysource/zabbix3.2
tar xf zabbix-3.2.7.tar.gz -C /usr/local/src/
cd /usr/local/src/zabbix-3.2.7/
./configure --prefix=/usr/local/zabbix --enable-server --with-mysql --with-net-snmp --with-libcurl --with-libxml2 --enable-agent --enable-ipv6
make
make install

#创建用户
useradd zabbix

#修改配置文件
sed -i '/# DBHost=/cDBHost=172.25.12.13' /usr/local/zabbix/etc/zabbix_server.conf
sed -i '/# DBPassword=/cDBPassword=123' /usr/local/zabbix/etc/zabbix_server.conf

#复制脚本databasezabbix.sh到database端执行
cd $yuanlujing
sh mysshid.sh 172.25.12.13 uplooking
ssh 172.25.12.13 "mkdir /zabbixinstall"
scp yum_shell.sh mysshid.sh databasezabbix.sh 172.25.12.13:/zabbixinstall
ssh 172.25.12.13 "sh /zabbixinstall/databasezabbix.sh"

#复制脚本webzabbix.sh到web端执行
#cd $yuanlujing
sh mysshid.sh 172.25.12.12 uplooking
ssh 172.25.12.12 "mkdir /zabbixinstall"
rsync -avz mysource/zabbix3.2 172.25.12.12:/zabbixinstall
scp yum_shell.sh mysshid.sh webzabbix.sh 172.25.12.12:/zabbixinstall
ssh 172.25.12.12 "sh /zabbixinstall/webzabbix.sh"

#复制脚本agentzabbix.sh到web端执行
#cd $yuanlujing
sh mysshid.sh 172.25.12.10 uplooking
ssh 172.25.12.10 "mkdir /zabbixinstall"
rsync -avz mysource/zabbix3.2 172.25.12.10:/zabbixinstall
scp yum_shell.sh mysshid.sh agentzabbix.sh 172.25.12.10:/zabbixinstall
ssh 172.25.12.10 "sh /zabbixinstall/agentzabbix.sh"


