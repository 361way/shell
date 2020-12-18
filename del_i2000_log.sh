#!/bin/bash
# site: www.361way.com   
# mail: itybku@139.com

backdel_logs()
{
        cd /opt/huawei/I2000/var/logs
        if [ $? -eq 0 ]; then
                #find . -type f -mtime +2 -print | xargs tar -czf /lv_oradata/huawei_backup/i2000_backup/logsbackup_`date +%s`.tar.g
z
                find . -type f -mmin +5 -print | xargs tar -czf /lv_oradata/huawei_backup/i2000_backup/logs/logsbackup_`date +%s`.ta
r.gz
                find /opt/huawei/I2000/var/logs -type f -mmin +5 -exec cp /dev/null {} \;
                find /opt/huawei/I2000/var/logs -type f -empty -delete
        fi
}

backdel_syslogs()
{
        cd /opt/huawei/I2000/var/syslogs
        if [ $? -eq 0 ]; then
                find . -type f -mmin +5 -print | xargs tar -czf /lv_oradata/huawei_backup/i2000_backup/logs/syslogsbackup_`date +%s`
.tar.gz
                find /opt/huawei/I2000/var/syslogs -type f -mmin +5 -exec cp /dev/null {} \;
                find /opt/huawei/I2000/var/syslogs -type f -empty -delete
        fi
}

per=`df /opt/ | grep opt | awk '{print $(NF-1)}'|sed 's/%//g'`
if [[ $per -gt 85 ]]; then
        backdel_logs
        backdel_syslogs
fi
