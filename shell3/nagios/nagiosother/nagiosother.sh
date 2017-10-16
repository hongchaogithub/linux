#!/bin/bash
#此脚本将被复制到被监控主机上执行
#定义用户和密码
useradd nagios
echo 123 |passwd --stdin nagios

#安装软件
wget ftp://172.25.254.250/notes/project/software/nagios/nagios-plugins-1.4.14.tar.gz
tar xf nagios-plugins-1.4.14.tar.gz
yum -y install gcc openssl-devel

#编译并安装
cd nagios-plugins-1.4.14
./configure
make
make install
cd ..

#修改所属
chown nagios. /usr/local/nagios
chown -R nagios. /usr/local/nagios/libexec

#安装其他相关软件
yum -y install xinetd lftp

#nrpe相关操作：编译、安装
lftp 172.25.254.250:/notes/project/software/nagios << end
get nrpe-2.12.tar.gz 
end

tar -xf nrpe-2.12.tar.gz
cd nrpe-2.12
./configure 
make all
make install-plugin
make install-daemon
make install-daemon-config
make install-xinetd
cd ..

#修改配置文件
sed -i '/only_from       = 127.0.0.1/conly_from       = 127.0.0.1 172.25.12.10' /etc/xinetd.d/nrpe
cat /etc/services |grep nrpe
ifexist=`echo $?`
[ $ifexist -ne 0 ] && echo "nrpe   5666/tcp #nrpe" >> /etc/services

cat /nagiosnrpe/nrpe.cfg > /usr/local/nagios/etc/nrpe.cfg
systemctl restart xinetd

