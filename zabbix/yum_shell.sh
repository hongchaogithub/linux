#!/bin/bash
#关闭防火墙
setenforce 0
iptables -F

#read -p "请输入iso路径：(直接回车按默认值安装)" lujing

#如果输入为空，赋值给默认路径
#if [ -z "$lujing" ]
#then
lujing=http://content.example.com/rhel7.1/x86_64/dvd
#fi

#将/etc/yum.repos.d目录下所有文件移走
mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/* /etc/yum.repos.d/bak/

#搭建yum源
cat >/etc/yum.repos.d/tmpdvd.repo <<end
[rhel_dvd]
gpgcheck = 0
enabled = 1
baseurl = $lujing 
name = Remote classroom copy of dvd
end

#安装软件
yum clean all
#yum makecache
for i in $@
do
yum -y install $i
#检测安装是否完成
if [ $? -eq 0 ]
then
echo "安装 $i 完成"
else
echo "$i 未安装成功，请检查路径或软件名是否正确或网络是否正常"
fi
done

#恢复/etc/yum.repos.d/目录现场
mv /etc/yum.repos.d/bak/* /etc/yum.repos.d/
rm -fr /etc/yum.repos.d/tmpdvd.repo /etc/yum.repos.d/bak 

