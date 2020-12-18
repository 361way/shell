#!/bin/bash
# site: www.361way.com
# mail: itybku@139.com

check_process(){
tolprocess=`ps auxf|grep DisplayMa[nager]|wc -l`

#if [ "$tolprocess" -lt "1" ];then
if [ "$tolprocess" -ge "1" ];then
	echo  'process ok'
else
	echo  'fail'
fi
}


check_log(){
if [ -e /etc/syslog-ng/syslog-ng.conf ];then
	conlog=`cat '/etc/syslog-ng/syslog-ng.conf'|grep "10.70.72.253"|wc -l`
        if [ "$conlog" -ge "1" ];then
        	echo 'syslog-ng ok'
        fi
elif [ -e /etc/syslog.conf  ];then
	conlog=`cat '/etc/syslog.conf'|grep "10.70.72.253"|wc -l`
	if [ "$conlog" -ge "1" ];then
      		echo 'syslog ok'
        fi
else
	echo 'log not find or error'
fi
}


check_cpuidle(){
mincpu=`sar -u 2 10|grep all|awk '{print $NF}'|sort -nr|tail -1`

if [ $(echo "${mincpu} < 20" | bc) = 1 ];then
#if [ "$mincpu" -le "20" ];then
	echo 'cpu idle is less than 20% ,please check'
else
	echo 'cpu idle is more than 20%, it is ok '
fi

}


check_mem(){
vmstat 2 10 
}


check_disk(){
chkdsk=`fdisk -l|egrep 'failed|unsynced|unavailable'|wc -l`
if [ "$chkdsk" -ge "1" ];then
        echo  'fdisk check ok '
else
        echo  'fdisk check find error,please check your disk '
fi
}


check_io(){
util=`sar -d 2 10|egrep -v 'x86|^$|await'|awk '{print $NF}'|sort -nr|tail -1`
await=`sar -d 2 10|egrep -v 'x86|^$|await'|awk '{print $(NF-2)}'|sort -nr|tail -1`

if [ $(echo "${util} < 80" | bc) = 1 ] && [ $(echo "${await} < 100" | bc) = 1 ] ;then
	echo 'disk io check is fine'
else
	echo 'disk io use too high '
fi

}


check_swap(){

tolswap=`cat /proc/meminfo|grep SwapTotal|awk '{print $2}'`
#awk '/SwapTotal/{total=$2}/SwapFree/{free=$2}END{print (total-free)/1024}'  /proc/meminfo  
useswap=`awk '/SwapTotal/{total=$2}/SwapFree/{free=$2}END{print (total-free)}'  /proc/meminfo `
util=`awk 'BEGIN{printf "%.1f\n",'$useswap'/'$tolswap'}'`


if [ $(echo "${util} < 0.3" | bc) = 1 ] || [ $(echo "${useswap} < 1024" | bc) = 1 ] ;then
        echo 'swap use is ok '
else
        echo "useswap: $useswap kb, swap util is $util"
fi

}


check_dmesg(){
chkdm=`dmesg |egrep 'scsi reset|file system full'|wc -l`
if [ "$chkdm" -ge "1" ];then
        echo  'dmesg test ok  '
else
        echo  'dmesg check find error '
fi
}

check_boot(){
chkdm=`cat /var/log/boot.msg|egrep 'scsi reset|file system full'|wc -l`
if [ "$chkdm" -ge "1" ];then
        echo  'boot check fine '
else
        echo  'boot check find error '
fi
}

check_inode(){
maxinode=`df -i|awk '{print $5}'|egrep -v 'IUse|-' |sed 's/%//g'|sort -nr|head -1`
if [ $(echo "${maxinode} < 80" | bc) = 1 ];then
        echo  'inode check ok  '
else
        echo  'inode used more than 80% '
fi
}

check_df(){
dfuse=`df -HT|awk '{print $6}'|grep -v Use|sed 's/%//g'|sort -nr|head -1`
if [ $(echo "${dfuse} < 80" | bc) = 1 ];then
        echo  'disk used is less than 80% ,it is ok !'
elif [ $(echo "${dfuse} > 80" | bc) = 1 ] && [ $(echo "${dfuse} < 90" | bc) = 1 ];then
        echo  'warning , disk used more than 80% and less than 90% '
else
        echo  ' Critical, disk used more than 90% '
fi
}


echo '################### check process ###################'
check_process
echo '################### check syslog ####################'
check_log
echo '################### check cpuidle ###################'
check_cpuidle
echo '################### echo memory stat ################'
check_mem
echo '################### check fdisk #####################'
check_disk
echo '################### check io used ###################'
check_io
echo '################### check swap used #################'
check_swap
echo '################### check dmesg #####################'
check_dmesg
echo '################### check inode #####################'
check_inode
echo '################### check disk used #################'
check_df

