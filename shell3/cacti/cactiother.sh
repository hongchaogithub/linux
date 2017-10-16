#!/bin/bash
#此脚本用于配置非本机的监控，请在包含本脚本的目录下的ipaddr.list文件中输入要监控的ip地址，并且用root身份登陆被监控主机，请确保密码正确

cat ipaddr.list|while read ip passwd
do
sh mysshid.sh $ip $passwd
ssh $ip "setenforce 0"
ssh $ip "iptables -F"
ssh $ip "yum -y install net-snmp"
rsync -avzR /etc/snmp/snmpd.conf $ip:/
ssh $ip "service snmpd start"
done
