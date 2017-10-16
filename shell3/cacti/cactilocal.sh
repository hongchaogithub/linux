#!/bin/bash
#请先进入脚本所在目录执行此脚本，脚本所在目录应包含yum-shell.sh脚本
#此脚本用于配置本地监控，若不需要监控本地请注释最后的代码
#关闭防火墙
setenforce 0
iptables -F


#安装软件
sh yum_shell.sh httpd php php-mysql mariadb-server mariadb lftp expect

#下载软件
lftp 172.25.254.250:/notes/project/UP200/UP200_cacti-master << eof
mirror pkg
exit
eof

cd pkg
yum localinstall cacti-0.8.8b-7.el7.noarch.rpm php-snmp-5.4.16-23.el7_0.3.x86_64.rpm << end
y
end

service mariadb restart
expect << eof
spawn mysql -p
expect "password:"
send "\n"
expect "none)]>"
send "create database cacti;\n"
send "grant all on cacti.* to cactidb@'localhost' identified by '123';\n"
send "flush privileges;\n"
send "exit\n"
expect eof
eof

#修改cacti配置文件
cat > /etc/cacti/db.php << end
<?php
\$database_type = "mysql";
\$database_default = "cacti";
\$database_hostname = "localhost";
\$database_username = "cactidb";
\$database_password = "123";
\$database_port = "3306";
\$database_ssl = false;
?>
end

#导入数据
mysql -ucactidb -p123 cacti < /usr/share/doc/cacti-0.8.8b/cacti.sql

#配置cacti虚拟主机
sed -i  's/Require host localhost$/Require all granted/' /etc/httpd/conf.d/cacti.conf

#配置php时区
sed -i "s%\;date.timezone =%date.timezone = \'Asia/Shanghai\'%" /etc/php.ini

#变更计划任务 --> 让其五分钟出一一次图
cat > /etc/cron.d/cacti <<end
*/5 * * * *     cacti   /usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1
end

#启动服务
service httpd restart
service snmpd start

#配置本机snmpd，若不需要监控本机，请注释以下代码
sed -i '/com2sec notConfigUser  default/ccom2sec notConfigUser  default       pubupl\nview    systemview    included   .1' /etc/snmp/snmpd.conf 

service snmpd restart


