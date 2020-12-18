#!/bin/bash
# ================================================================
#   Copyright (C) 2018 www.361way.com site All rights reserved.
#   
#   Filename      ：pings.sh
#   Author        ：yangbk <itybku@139.com>
#   Create Time   ：2018-10-24 09:15
#   Description   ：从zabbix获取主机列表，并去掉黑名单后，进行
#                   ping check,发现有不通的，进行告警发送
# ================================================================

Pingchecks() {
	i=0
	while [[ $i -le 2160 ]]; do

		diff $SORTHOSTS $BLACKHOSTS |grep '<'|awk '{print $NF}' > $CHECKHOSTS
		#fping -f hosts -r 3 -s -q -u > $UNREACH
		fping -f $CHECKHOSTS -r 3 -q -u > $UNREACH
		count=`cat $UNREACH|wc -l`
		echo `date +"%F %T"`" 告警不可达主机数："$count
		if [[ $count -ge 1 ]]; then

			for host in `cat $UNREACH`;do
				sipc=`grep "^${host}$"  $SMSHOSTS|wc -l`
				if [[ $sipc -gt 3 ]]; then
					 echo '主机'$host'发送超过3条，告警压制！'
				else
					 echo '主机'$host'无法ping通，发送告警。'
					 echo $host>>$SMSHOSTS
				fi
			done

			# sc = send count
			sc=`cat $SMSHOSTS|wc -l`
			echo "检查恢复主机，正常主机从列表中清理"
			if [[ $sc -ge 1 ]]; then
				for host in `cat $SMSHOSTS`;do
					alc=`grep "^${host}$" $UNREACH|wc -l`
					if [[ $alc -lt 1 ]]; then 
			       		echo $host“恢复正常，从告警列表中移除...”
						sed -i '/^'$host'$/d' $SMSHOSTS
					fi
				done
			fi
	         
		fi
		let i++
		echo '========================================'
		sleep 1
	done		
}


mkdir hosts
echo "请确认存在black.hosts需要屏蔽的主机"
while true; do
	DBHOSTS=./hosts/01db.hosts
	SORTHOSTS=./hosts/02sort.hosts
	CHECKHOSTS=./hosts/03check.hosts
	SMSHOSTS=./hosts/04sms.hosts
	BLACKHOSTS=./hosts/05black.hosts
	UNREACH=./hosts/06unreach.hosts


	touch $BLACKHOSTS
	mysql -h 192.168.1.1 -u zabbix -p'zabbixpassword' zabbix  -e 'select ip from interface where hostid not in (select hostid from hosts where status=1)' > $DBHOSTS
	grep -v ip $DBHOSTS |sort |uniq > $SORTHOSTS
	>$SMSHOSTS
	Pingchecks
done
