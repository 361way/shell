#!/usr/bin/env python

#coding=utf-8

import sys, os.path, time
import urllib

def usage():
    '''usage'''
    print 'Usage: %s %s %s' %(sys.argv[0],'PhoneNumber', 'Subject', 'Message')
    sys.exit()

def sms_interface(phone, message):
    '''The SMS interface'''
    url = 'http://192.168.10.100:9703/mktweb/mo'
    message = urllib.quote(message)
    postdata = 'from=1065808066666&transactionid=&channelid=8&to=%s&subject=Alarm&content=%s&msgtype=0&mmstype=&wapurl=' %(phone, message)
    
    try:
        urllib.urlopen(url, postdata)
    except:
        print 'The sms send failed!'


def main():
    if len(sys.argv) != 3:
        usage()
    phone = sys.argv[1]
    subject = sys.argv[2]
    #message = sys.argv[3]
    sms_interface(phone, subject)

if __name__ == "__main__":
    main()
