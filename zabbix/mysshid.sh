#!/bin/bash
#此脚本用于推送密钥，有可能使以前的密钥失效，也有可能使以前推送过密钥的主机不再配对，执行本脚步后需要对以前推送过密钥且本脚本没有执行过的主机重新推送密钥，请确保密码正确

rm -fr /root/.ssh/id_rsa*

#生成密钥
expect <<EOF
spawn ssh-keygen
expect "id_rsa):"
send "\n"
expect "passphrase):"
send "\n"
expect "again:"
send "\n"
expect eof
EOF

#推送密钥
expect <<EOF
spawn ssh-copy-id root@$1 -o StrictHostKeyChecking=no
expect "word:"
send "$2\n"
expect eof
EOF
