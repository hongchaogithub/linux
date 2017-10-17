#!/bin/bash
#此脚本在agent端执行
echo '#######################agent端开始安装################################'
#关闭防火墙
setenforce 0
iptables -F

#设置时区和更新时间
timedatectl set-timezone Asia/Shanghai
ntpdate -u 172.25.254.254

#安装软件
cd /zabbixinstall/zabbix3.2
rpm -ivh zabbix-agent-3.2.7-1.el7.x86_64.rpm 
sh /zabbixinstall/yum_shell.sh net-snmp net-snmp-utils 

#修改配置文件
sed -i '/^Hostname=/cHostname=servera.pod12.example.com' /etc/zabbix/zabbix_agentd.conf
sed -i '/^ServerActive=/cServerActive=172.25.12.11' /etc/zabbix/zabbix_agentd.conf
sed -i '/^Server=/cServer=172.25.12.11' /etc/zabbix/zabbix_agentd.conf
sed -i '/UnsafeUserParameters=/cUnsafeUserParameters=1' /etc/zabbix/zabbix_agentd.conf

#启动服务
systemctl start zabbix-agent
systemctl enable zabbix-agent
