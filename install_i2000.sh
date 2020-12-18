#!/bin/bash
# site: www.361way.com   
# mail: itybku@139.com

ftp_host="192.168.1.1"
ftp_user="root"
ftp_password="123456"
remote_folder="/root"
amos_folder="/opt/breeze"
downloadlog="${amos_folder}/download.log"
amosfile="BRZV100R001C09LINUX.tar"

Download() {
    if [ -d $amos_folder ]; then
        echo 'will be download amosfile now'
    else
        mkdir $amos_folder
    fi
#ftp -niv $ftp_host>>${downloadlog}<<EOF 
ftp -n $ftp_host>>${downloadlog}<<EOF 
    user $ftp_user $ftp_password
    lcd $amos_folder
    cd $remote_folder
    prompt off
    bin
    get $amosfile
    bye
EOF
}

CleanCrontab() {
    CRON_TMP_FILE="/tmp/cronfiletmp"
    crontab -l | grep -v "CronAmosStartup.sh" > $CRON_TMP_FILE
    crontab $CRON_TMP_FILE
    rm -f $CRON_TMP_FILE
    echo "Remove CronAmosStartup.sh from crontab successfully."
}

CleanRcScript() {

    chkconfig -s AmosStartup off 1>/dev/null 2>&1
    rm -f /etc/rc.d/AmosStartup 1>/dev/null 2>&1
    echo "Remove /etc/rc.d/AmosStartup successfully."
    rm -f /usr/bin/amos* 1>/dev/null 2>&1
}

Backup_monitor() {
    if [ -d $amos_folder/monitor ]; then
        amosagt stop
        mv  "$amos_folder/monitor"   "$amos_folder/monitor_`date +%y%m%d`"
        CleanCrontab
        CleanRcScript  
    fi
} 

Decompression() {
    cd $amos_folder
        tar xvf BRZV100R001C09LINUX.tar 
        unzip iMonitor.tar.zip
        tar xf iMonitor.tar

}

Permission() {

    if [ -d $amos_folder/monitor ]; then

        chmod 755 $amos_folder/monitor 1>/dev/null 2>&1
        chmod 755 $amos_folder/monitor/monalarm 1>/dev/null 2>&1
        chmod 755 $amos_folder/monitor/monalarm/cfg 1>/dev/null 2>&1
        chmod 755 $amos_folder/monitor/monalarm/cfg/amosorasyn.sql 1>/dev/null 2>&1
        if [ -f $amos_folder/monitor/brztrapagt/cfg/brzmntrproc.cfg ]; then
            chmod 600 $amos_folder/monitor/brztrapagt/cfg/brzmntrproc.cfg 1>/dev/null 2>&1
        fi
        if [ -f $amos_folder/monitor/snmpproxy/cfg/dbmonitor.cfg ]; then
            chmod 600 $amos_folder/monitor/snmpproxy/cfg/dbmonitor.cfg 1>/dev/null 2>&1
        fi
    fi

}

Replaceconf() {
    cd $amos_folder/monitor/cfg
    sed -i '/^alarm_target/calarm_target        = 192.168.1.10:10162;192.168.1.100:18999' global.cfg
    sed -i '/^read_community/cread_community      = cmread' global.cfg

    dcnip=`ip add show|grep '10.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|awk '{print $2}'|awk -F/ '{print $1}'`
    sed -i "/^local_ip/clocal_ip            = $dcnip" global.cfg
}

Download
Backup_monitor
Decompression
Permission
if [ -d $amos_folder/monitor_`date +%y%m%d` ]; then
    mv "$amos_folder/monitor/cfg"   "$amos_folder/monitor/cfg_bak" 
    cp -rp "$amos_folder/monitor_`date +%y%m%d`/cfg" "$amos_folder/monitor/"
else
    Replaceconf
fi

cd $amos_folder
sh monitor/bin/setup.sh 
amosagt start
rm -rf "$amos_folder/iMonitor.tar.zip"    "$amos_folder/iMonitor.tar"    "$amos_folder/iMonitor.tar/unzip"
