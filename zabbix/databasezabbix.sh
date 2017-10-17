#!/bin/bash
#此脚本在database上执行
echo '#######################database端开始安装################################'
#关闭防火墙
setenforce 0
iptables -F

#设置时区和更新时间
timedatectl set-timezone Asia/Shanghai
ntpdate -u 172.25.254.254

#安装软件
cd /zabbixinstall
sh yum_shell.sh mariadb-server mariadb expect

systemctl start mariadb
systemctl enable mariadb


#复制数据库文件并导入
sh mysshid.sh 172.25.12.11 uplooking
scp 172.25.12.11:/usr/local/src/zabbix-3.2.7/database/mysql/* /root/ && echo "复制成功！"

mysql << end
create database zabbix default charset utf8;
grant all on zabbix.* to zabbix@'%' identified by '123';
flush privileges;
end

#expect << eof
#spawn mysql -p
#expect "password:"
#send "\n"
#expect "none)]>"
#send "create database zabbix default charset utf8;\n"
#send "grant all on zabbix.* to zabbix@'%' identified by '123';\n"
#send "flush privileges;\n"
#send "exit\n"
#expect eof
#eof

mysql zabbix < /root/schema.sql && echo "schema.sql导入成功！"
mysql zabbix < /root/images.sql && echo "images.sql导入成功！"
mysql zabbix < /root/data.sql && echo "data.sql导入成功！"

#更改中文环境
mysqldump zabbix > /tmp/zabbix.sql
sed -i 's/latin1/utf8/' /tmp/zabbix.sql
mysql zabbix < /tmp/zabbix.sql && "更改中文环境成功！"










