#!/bin/bash
for i in {a..j}
do
expect <<EOF 
spawn rht-vmctl reset server$i
expect "(y/n)"
send "y\n"
expect eof
EOF
rht-vmctl stop server$i
done
