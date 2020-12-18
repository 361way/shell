#!/bin/bash
# usedMem(kB) TotalMEM(kB) used1_percent(no eredundance)  used1_percent(redundance)
used=`free -m|grep 'buffers/cache'|awk '{print $(NF-1)}'`
used_redu=`free -m|grep 'buffers/cache'|awk '{print $(NF-1)+4096}'`
total=`cat /proc/meminfo |grep MemTotal |awk '{print $2/1024}'`
used_value=$(echo $used $total | awk '{ printf "%0.2f\n" ,$1/$2}')
usedredu_value=$(echo $used_redu $total | awk '{ printf "%0.2f\n" ,$1/$2}')
dcnip=`/sbin/ifconfig|grep inet|grep 10|awk '{print $2}'`
echo "$dcnip |  $used  | $total | $used_value | $usedredu_value "
