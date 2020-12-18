#!/bin/bash
## author: yangbk
## site: www.361way.com
## mail: itybku@139.com
## desc: test wait and ssh when use for in and while 

# while loop
echo -en "\t";date
cat abc.txt|while read user ip
do
{
 ssh -o ConnectTimeout=10 $user@$ip "hostname" < /dev/null
 sleep 10s
} &
done
wait
echo "This is while loop."
echo -en "\t";date

sleep 10s
echo -e "\n"

# for loop
echo -en "\t";date
for line in `cat abc.txt|sed -e 's/ /--/g'`
do
{
 user=`echo $line|awk -F '--' '{print $1}'`
 ip=`echo $line|awk -F '--' '{print $2}'`
 ssh -oConnectTimeout=10 $user@$ip "hostname"
 sleep 10s
} &
done
wait
echo "This is for loop."
echo -en "\t";date
