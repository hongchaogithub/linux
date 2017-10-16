#!/bin/bash
#若不需要监控本机，请注释特定代码
#安装软件
yum -y install lftp expect
lftp 172.25.254.250:/notes/project/UP200/UP200_nagios-master << end
mirror pkg
end
cd pkg
yum localinstall *.rpm << end
y
end

#设置nagios密码文件
expect << eof
spawn htpasswd -c /etc/nagios/passwd nagiosadmin
expect "password:"
send "123\n"
expect "password:"
send "123\n"
expect eof
eof

#启动服务
systemctl restart httpd
#systemctl start nagios

#修改配置文件并重启服务
#rm -fr /etc/nagios/objects/localhost.cfg
cd ..
cat cfg/localhost.cfg > /etc/nagios/objects/localhost.cfg
service nagios restart

#监控本机，若不需监控本机，请注释两个注释间的代码
yum -y install net-snmp net-snmp-utils
systemctl restart snmpd
#监控本机，若不需监控本机，请注释两个注释间的代码

#以下为监控其他主机的代码
#修改配置文件
cat /etc/nagios/objects/commands.cfg |grep check_nrpe
ifexist=`echo $?`
if [ $ifexist -ne 0 ]
then
cat >> /etc/nagios/objects/commands.cfg << end
define command{
        command_name check_nrpe
        command_line /check_nrpe -H \$HOSTADDRESS\$ -c \$ARG1\$
}
end
fi

cat cfg/serverb.cfg > /etc/nagios/objects/serverb.cfg

cat /etc/nagios/nagios.cfg |grep 'cfg_file=/etc/nagios/objects/serverb.cfg'
ifexist=`echo $?`
if [ $ifexist -ne 0 ]
then
sed -i '/local (Linux) host$/acfg_file=/etc/nagios/objects/serverb.cfg' /etc/nagios/nagios.cfg
fi

systemctl restart nagios

#复制被监控主机使用的脚本到被检控主机执行
pwd
sh mysshid.sh 172.25.12.11 uplooking
ssh 172.25.12.11 "mkdir /nagiosnrpe"
scp nagiosother/* 172.25.12.11:/nagiosnrpe
ssh 172.25.12.11 "sh /nagiosnrpe/nagiosother.sh"



