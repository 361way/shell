#!/bin/bash
# author: code by yangbk <www.361way.com>
# desc: for strace oracle when occurring problem 

while true; do


        value=`su - oracle -c 'sh /home/oracle/check_logfilesync.sh'`
        echo `date +'%Y-%m-%d %H:%M:%S'` -- $value >> /opt/cmcc/strace/logfull.txt
        if [[ $value -ge 1 ]]; then
                cd /opt/cmcc/strace
                strace -ftr -o strace_`date +%y%m%d%H%M%S`.log -p `pgrep -f ora_lgwr` &
                sleep 60
                killall strace
        fi

        sleep 5 
done
