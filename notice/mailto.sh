#!/bin/bash
# www.361way.com <itybku@139.com>
# 发送值班邮件给当天的值班人员，遇到周末，在周五提前发出。

cd /usr/local/notice
DATA=`date +'%Y-%m-%d'`
WEEKD=`date +%w`

#tomorrow=`date -d '1 days' "+%Y-%m-%d"`
#aftertom=`date -d '2 days' "+%Y-%m-%d"`


if [ $WEEKD -eq 5 ];then
  mails="`grep -A2 $DATA members.txt|awk '{print $4 }'|tr '\n' ','`"

  #使用八进制\134\156表示\n
  message=`grep -A2 $DATA members.txt|awk '{print $2":",$1,"号该您X86值班，请及时查看当天的告警信息!\134\156" }'`
  messages=`echo '周五（今天）、周六、周日三天的x86值班安排如下：\n'$message`
  #echo $mails,$messages
  #python sendPmail.py $mails ${messages} 
  ./sendEmail -u 'x86值班告警' -m $messages  -xu username -xp password -f itybku@163.com  -s smtp.163.com -o  message-charset=utf-8  -t $mails 

else
  name=`grep $DATA  members.txt|awk '{print $2}'`
  mails=`grep $DATA members.txt|awk '{print $4 }'`
  messages=`echo hi,$name! 今天\(${DATA}\)该您X86值班，请及时查看当天的告警信息！`
  #python sendPmail.py $mails ${messages}
  echo $mails,$messages
  ./sendEmail -u 'x86值班告警' -m $messages  -xu username -xp password -f itybku@163.com  -s smtp.163.com -o  message-charset=utf-8  -t $mails 
fi

