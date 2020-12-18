#!/bin/bash

while read serverinfo; do
        sp=${serverinfo:0:1}
        if [ $sp == '#' ]; then
                continue
        fi

        IP1=`echo $serverinfo | awk -F',' '{print $1}'`
        USER1=`echo $serverinfo | awk -F',' '{print $2}'`
        PASSWD1=`echo $serverinfo | awk -F',' '{print $3}'`
        sshpass -p "$PASSWD1" scp -o StrictHostKeyChecking=no  mem.sh $USER1@$IP1:/tmp/
        sshpass -p "$PASSWD1" ssh  -o StrictHostKeyChecking=no  $USER1@$IP1 "sh /tmp/mem.sh"
        sshpass -p "$PASSWD1" ssh  -o StrictHostKeyChecking=no  $USER1@$IP1 "rm -rf  /tmp/mem.sh"
done < serverinfo.list
