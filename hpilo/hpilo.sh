#!/bin/bash
# auto set the Blade ilo address
# code from www.361way.com <itybku@139.com>

oaip='192.168.1.100'
password='password'
oamask='255.255.255.0'
gateway='192.168.1.1'
num=79

setgate="set ebipa server gateway $gateway all \n"

cat>autoexec.exp<<EOF
#!/usr/bin/expect
spawn ssh admin@$oaip
expect {
    "(yes/no)?" {
        send "yes\n"
        expect "assword:"
        send "$password\n"
    }
        "assword:" {
        send "$password\n"
    }
}
EOF

for((i=1; i<17; i++));do
let m=$i+$num
setip="set ebipa server 192.168.1.$m $oamask  $i \n"
#setgate="set ebipa server gateway $gateway $i \n"

cat>>autoexec.exp<<EOF
expect "*>"
send "$setip"
expect "*bays?"
send "YES\n"
expect eof
#interact
EOF

done

expect -f autoexec.exp


cat>gateway.exp<<EOF
#!/usr/bin/expect

spawn ssh admin@$oaip
expect {
    "(yes/no)?" {
        send "yes\n"
        expect "assword:"
        send "$password\n"
    }
        "assword:" {
        send "$password\n"
    }
}
expect "*>"
send "$setgate"
expect "Are you sure*$gateway?"
send "YES\n"
expect "*>"
send "SAVE EBIPA \n"
expect "*>"
send "ENABLE EBIPA SERVER all \n"
expect "*device (iLO) bays?"
send "YES\n"
expect eof
#interact
EOF
expect -f gateway.exp

sleep 2
rm -rf autoexec.exp gateway.exp 
