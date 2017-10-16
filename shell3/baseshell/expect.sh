#!/bin/bash
#此脚本专用于测试和作样板
expect << eof
spawn mysql -p
expect "password:"
send "123\n"
expect "none\)\]\>"
send "show databases;\n"
send "exit\n"
expect eof
eof

#send "exit\n"
