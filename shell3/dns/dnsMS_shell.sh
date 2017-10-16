#!/bin/bash
#批量部署DNS从服务器
#此脚本维护了一个DNS从服务器列表文件，请在/myetc_txt/slaves/目录下修改slaveslist.txt文件,目前只支持root用户登陆
sh yum
scp /
mv /root/.ssh/known_hosts /root/.ssh/known_hosts.bak
while read ip passwd
do
expect <<end
spawn ssh root@$ip
expect "(yes/no)?"
send "yes\n"
expect "password:"
send "$passwd\n"
expect "#"
send "sh /tmp/dnslave.sh"
expect eof
end
done < /myetc_txt/slaves/slaveslist.txt
