#!/bin/bash
# www.361way.com <itybku@139.com>
# 调用短信接口通知当天值班人员

cd /usr/local/notice
DATA=`date +'%Y-%m-%d'`
info=`grep $DATA  members.txt`
name=`echo $info |awk '{print $2}'`
phonenum=`echo $info |awk '{print $3}'`
#echo $DATA $name $phonenum
message="hi,$name,今天该您X86值噢，请记得关注当天的告警！"
python sms.py $phonenum $message
