#!/bin/bash
#在解压压缩包后，请不要移动其中的文件和目录
#自动部署DNS服务器，请在/myetc_txt/dns/acl目录下修改cfg文件中的acl地址
#请在/myetc_txt/dns/zone目录下修改A记录文件
#请在/myetc_txt/dns/acl目录下修改

sh /shell/exam/yum_shell.sh bind

#mkdir /myetc_txt
tar xf dns.tar.gz -C /
cat /myetc_txt/dns/named.conf.txt > /etc/named.conf
cat /myetc_txt/dns/zone/abc.com.dx.zone.txt > /var/named/abc.com.dx.zone
cat /myetc_txt/dns/zone/abc.com.wt.zone.txt > /var/named/abc.com.wt.zone
cat /myetc_txt/dns/zone/abc.com.other.zone.txt > /var/named/abc.com.othor.zone

chgrp named /var/named/abc.com.*

service named restart
chkconfig named on

cat /myetc_txt/dns/acl/wt.cfg.txt > /etc/wt.cfg
cat /myetc_txt/dns/acl/dx.cfg.txt > /etc/dx.cfg
cat /myetc_txt/dns/acl/other.cfg.txt > /etc/other.cfg











