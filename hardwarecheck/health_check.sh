#!/bin/bash
# write by yangbk,for check hardware health
# www.361way.com <itybku@139.com>

#######################################################
# 146 147 148 三框ping不通，需要登录到BI跳板机上操作
######################################################

Ciscoblade () {
IPs='''
192.168.1.1
192.168.1.2
192.168.1.3
192.168.1.4
'''
for IP in $IPs;do
    echo $IP
    echo "========================================="
    sshpass -p'*IK<0okm' ssh -o StrictHostKeyChecking=no admin@$IP 'show service-profile status' 
done

}

IBMblade () {
   cat inventory/IBMblade.txt|while read IP USERNAME PASSWORD
   do 
      echo $IP
      echo "========================================="
      sshpass -p$PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$IP 'health -l all' < /dev/null
   done
}

hpblade () {
for OAIP  in  `cat inventory/hpblade.txt`;do
    echo $OAIP
    echo "========================================="
    sshpass -p'mypassword' ssh -o StrictHostKeyChecking=no admin@$OAIP 'show server status all'|grep -i Health
    echo
    done

    echo '192.168.8.88'
    sshpass -p'password03' ssh -o StrictHostKeyChecking=no admin@192.168.8.88 'show server status all'|grep -i Health
}

hppcstorage () {
  cat inventory/hppc.txt|while read IP USERNAME PASSWORD
  do
      echo $IP
      echo "========================================="
      #sshpass -p$PASSWORD ssh -o StrictHostKeyChecking=no $USERNAME@$IP -a "show /system1/drives1" |grep Bay
      #ipmitool -I lanplus  -H $IP -U$USERNAME -P$PASSWORD sdr list|grep -v disabled
      cmd='sshpass -p"'${PASSWORD}'" ssh -o StrictHostKeyChecking=no '$USERNAME'@'$IP' -a "show /system1/drives1"'
      echo $cmd|bash|grep -i Bay
      echo  
  done
}

hppchealth () {
  cat inventory/hppc.txt|while read IP USERNAME PASSWORD
  do
      echo $IP
      echo "========================================="
      cmd=`curl -s -k -u $USERNAME:"$PASSWORD" https://$IP/json/health_summary`
      echo ${cmd}|/usr/local/bin/jq .
      echo  
  done
}

############################################################
  # for ipmihealth fun
  # $1 hostname file
  # $2 open/lan/lanplus
  # $3 username
  # $4 password
  # you can use `grep -v ok  log.txt|less` find error info
############################################################

ipmihealth () {

  for IP in `cat inventory/$1`;do
     echo $IP
     echo "========================================="
     ipmitool -I $2  -H $IP -U$3 -P$2 sdr list
     echo 
  done
}

echofile () {
  echo "# 生成日期 `date +%Y%m%d`" > logs/IBM_BLADE.txt 
  echo "# 生成日期 `date +%Y%m%d`" > logs/HP_BLADE.txt
  echo "# 生成日期 `date +%Y%m%d`" > logs/HPPC_DISK.txt
  echo "# 生成日期 `date +%Y%m%d`" > logs/HPPC_state.txt
  echo "# 生成日期 `date +%Y%m%d`" > logs/IBM_PC.txt
  echo "# 生成日期 `date +%Y%m%d`" > logs/Huawei.txt 
  echo "# 生成日期 `date +%Y%m%d`" > logs/DELL.txt
  echo "# 生成日期 `date +%Y%m%d`" > logs/Inspur.txt
  echo "# 生成日期 `date +%Y%m%d`" > logs/Cisco_BLADE.txt

}

cd /usr/local/health
rm -rf logs/*.txt
echofile
IBMblade >> logs/IBM_BLADE.txt
hpblade >> logs/HP_BLADE.txt
hppcstorage >> logs/HPPC_DISK.txt
hppchealth >> logs/HPPC_state.txt
ipmihealth 'ibmpc.txt' open  USERID  PASSW0RD >> logs/IBM_PC.txt 2>&1 
ipmihealth 'huawei.txt' open  root  'Huawei12#$' >> logs/Huawei.txt 2>&1 
ipmihealth 'dell.txt' open  root  calvin >> logs/DELL.txt 2>&1 
ipmihealth 'inspur.txt' open  admin  admin >> logs/Inspur.txt 2>&1 

Ciscoblade >> logs/Cisco_BLADE.txt
# 最后可以增加下把这些txt生成的文件，放到webserver目录下，并开启index索引查看。
