#!/bin/bash
#此脚本在web上执行
echo '#######################web端开始安装################################'
#关闭防火墙
setenforce 0
iptables -F

#设置时区和更新时间
timedatectl set-timezone Asia/Shanghai
ntpdate -u 172.25.254.254

#安装软件
cd /zabbixinstall
sh yum_shell.sh lftp httpd php php-mysql

#下载软件
#lftp 172.25.254.250:/notes/project/software/zabbix << end
#mirror zabbix3.2/
#exit
#end

cd /zabbixinstall/zabbix3.2
#cd zabbix3.2
yum -y localinstall php-mbstring-5.4.16-23.el7_0.3.x86_64.rpm php-bcmath-5.4.16-23.el7_0.3.x86_64.rpm
yum localinstall zabbix-web-3.2.7-1.el7.noarch.rpm zabbix-web-mysql-3.2.7-1.el7.noarch.rpm << end
y
end

#变更web端相关配置文件，指定时区
sed -i '/php_value date.timezone/cphp_value date.timezone Asia/Shanghai' /etc/httpd/conf.d/zabbix.conf

#安装字体
sh yum_shell.sh wqy-microhei-fonts

cp source/simkai.ttf /usr/share/zabbix/fonts/
sed -i 's/graphfont/simkai/' /usr/share/zabbix/include/defines.inc.php

#启动所有相关服务软件
sh mysshid.sh 172.25.12.11 uplooking
ssh 172.25.12.11 << end
cd /usr/local/zabbix/sbin
pwd
echo ****************************************
./zabbix_server && echo 'zabbix启动成功！' || echo '启动失败！'
end

systemctl restart httpd && echo 'httpd启动成功！'
systemctl enable httpd

