#!/bin/bash
# code by yangbk  < www.361way.com   itybku@139.com >
## echo time pid user cpu% %mem ##
# awk '{print $NF,$1,$2,$(NF-3),$(NF-2)}' cpumem_20170105 
#
## echo all pids ##
# top -b -n 1|grep -i java|awk '{print $1}'
# 
# add the shell to the crontab ,logrotate the output by days
# 0 0 * * * root /var/log/monitor/$0 &

CURDAY=`date +%Y%m%d`
LOGPATH=/var/log/monitor
INTERVAL=30
USERS='ts_up  ts_bookm'

monitor_io() {

	PIDC=`ps auxf|grep ioto[p]|wc -l`
	PID=`ps auxf|grep ioto[p]|awk '{print $2}'`

	if [ $PIDC -gt 0 ];then
	        kill -USR2 $PID
	fi
	sleep 3
	iotop -q -P -b -t -o -k -d $INTERVAL >> $LOGPATH/IO_$CURDAY &
}

cpu_mem() {
	killall top
	for user in USERS;do
		top -u $user  -b  -d $INTERVAL >> $LOGPATH/$user_$CURDAY.top &
	done
}

monitor_java() {
	if [ -e 'run.pid' ] && ps `cat run.pid` | grep $0 > /dev/null ;then

		kill -USR2 `cat run.pid`
		rm run.pid
	fi

	echo $$ > run.pid

	# you can use ps command to get the cpu and mem used also .
	while true; do
		rq=`date  +%H:%M:%S`;top -b -n 1|grep -i java|awk  '{$NF=rq ;print $0}' rq="$rq" >> $LOGPATH/cpumem_$CURDAY
		sleep $INTERVAL
	done
}

dellogs() {
	( (sleep 3; find $LOGPATH -name 'IO_*' -mtime +4 -exec rm {} \;)& )
	#( (sleep 3; find $LOGPATH -name '*.top' -mtime +4 -exec rm {} \;)& )
	( (sleep 3; find $LOGPATH -name 'cpumem_*' -mtime +4 -exec rm {} \;)& )
}

monitor_io
dellogs
monitor_java
