#!/bin/bash
# site: www.361way.com   
# mail: itybku@139.com
#set -x
ip_list="192.168.17.74 192.168.17.111 192.168.17.110 192.168.17.107 192.168.17.109 192.168.17.82 192.168.17.108"


log_size=150982738

function useage()
{
   echo "ping_check.sh help:"
   echo "./ping_check.sh start             start the ping check"
   echo "./ping_check.sh stop              stop the ping check"
   echo "./ping_check.sh status            check the ping status"
   echo "the check output is /var/log/ping_check.log"
}

function start_check()
{
   ret=`ps -ef | grep "ping_check" | grep -v grep |grep -v $$`
   if [ "x$ret" != "x"  ]; then
     echo "ping_check is running"
     exit 0
   fi
   
   check &
}


function stop_check()
{
  ret=`ps -ef | grep "ping_check" | grep -v grep | grep -v $$`
   if [ "x$ret" = "x"  ]; then
     echo "ping_check is already stop"
     exit 0
   fi

  pid=`ps -ef | grep "ping_check" | grep -v grep | grep -v $$ | awk '{print $2}'` 
  if [ "x$pid" != "x" ]; then
     kill -9 $pid
  fi
}

function status_check()
{

   ret=`ps -ef | grep "ping_check" | grep -v grep | grep -v $$`
   if [ "x$ret" != "x"  ]; then
     echo "ping_check is running"
   else
     echo "ping_check is not running"
   fi
}

function writelog()
{
  loginfo=$1
  if [ ! -d /var/log ];then
      mkdir -p /var/log
  fi
  
  touch /var/log/ping_check.log
  
  filesize=`ls -l /var/log/ping_check.log | awk '{ print $5 }'`

  if [ $filesize -ge $log_size ]; then
     mv /var/log/ping_check.log /var/log/ping_check.logbak
     echo "">/var/log/ping_check.log 
  fi 
 
  echo $loginfo >>/var/log/ping_check.log
}

function check()
{
while :
do
  for ip in $ip_list                               
  do                        
    date=`date`                              
    ret=`ping $ip -c1 | grep "icmp_seq"`                                   
    if [ $? -ne 0 ];then                                    
      #echo $date: $ip is offline [$ret] >>/var/log/ping_check.log
      writelog "$date: $ip is offline [$ret] "                          
    else                                                   
      #echo $date: $ip is online  [$ret] >>/var/log/ping_check.log
      writelog "$date: $ip is online  [$ret] "                        
    fi                                                   
  done     
  sleep 1
done

}


if [ $# -ne 1 ];then
  useage
  exit 0 
fi

if [ "x$1" = "xstart" ]; then
  start_check
elif [ "x$1" = "xstop" ]; then
  stop_check
elif [ "x$1" = "xstatus" ]; then
  status_check
else
  useage
fi


