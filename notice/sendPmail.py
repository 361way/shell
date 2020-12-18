#!/usr/bin/env python
# coding:utf8
import sys
reload(sys)
sys.setdefaultencoding("utf-8")

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import smtplib

msg = MIMEMultipart('alternative')
print len(sys.argv)
text = " ".join(sys.argv[2:])
print text

if isinstance(text,unicode):
   text = str(text)

part1 = MIMEText(text, 'plain','utf-8')
msg.attach(part1)

subject = 'X86值班告警'
if not isinstance(subject,unicode):
   subject = unicode(subject)

tolist = str(sys.argv[1])
print tolist
#msg['to'] = ", ".join(tolist)
msg['to'] = tolist
msg['from'] = 'itybku@163.com'
msg['subject'] = subject
msg["Accept-Language"]="zh-CN"
msg["Accept-Charset"]="ISO-8859-1,utf-8"

try:
    server = smtplib.SMTP()
    server.connect('smtp.163.com')
    server.login('username','password')
    server.sendmail(msg['from'], tolist,msg.as_string())
    server.quit()
    print '发送成功'
except Exception, e:
    print str(e)
