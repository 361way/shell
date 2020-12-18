#!/bin/bash
#Author  yanbk  20151203
#power by www.361way.com

#######################################################
#     Test mount the storage and write a file         #   
#######################################################

count=`ls /media|wc -l`
if [ $count != 0 ];then
      echo '/media dir is not empty'
else
      echo 'OK , /media is empty'
fi

teststorage(){
    mount.nfs  192.168.14.12:lv_kdump  /media/
    echo "I'will be write host ip in storage test file !"
    echo "`hostname -i`" > /media/test
    echo -e "Now,we will read the test file.The Content of the test file is:\n"
    cat /media/test
    echo -e "\n"
    umount /media/ 
    read  -p "Are you sure find your host IP above[Y/N]?" answer 
    case $answer in
    Y | y)
	
	    echo "Congratulations !!! we can write the storage"	
        ;;

    N | n)

        echo "Please recheck write file in the storage by manual"
        exit 1
        ;;

        *)

        echo "error choice"
        exit 1
        ;;
     esac
}



read  -p "Do you want to test mount the storage and write a file [Y/N]?" answer 
case $answer in 

    Y | y) 
     	teststorage
        ;;
    N | n) 

        echo "Sorry,I'will be exit!"
        exit 1
        ;; 

        *) 

        echo "error choice"
        exit 1
        ;; 
 esac


#######################################################
#     Backup the kdump config and kdump img           #
#######################################################

echo 'Your system version is:'
if [ -f /etc/redhat-release ];then
    cat /etc/redhat-release
    SYSVERSION='1'
elif [ -f /etc/SuSE-release ];then
    cat /etc/SuSE-release
    SYSVERSION='2'
fi 

#echo 'SYSVERSION:' $SYSVERSION

read  -p "Do you want to backup kdump config and kdump img [Y/N]?" answer 
case $answer in 

    Y | y) 

      if [ $SYSVERSION = '1' ];then 
          echo 'Your system is redhat ! Backup now !'
          cp /etc/kdump.conf  /etc/kdump.conf_`date +%Y%m%d`
          mv /boot/initrd-`uname -r`kdump.img  /boot/initrd-`uname -r`kdump.img_`date +%Y%m%d`
      elif [ $SYSVERSION = '2' ];then    
          echo 'Your system is SuSE ! Backup now !'
          cp /etc/sysconfig/kdump  /etc/sysconfig/kdump_`date +%Y%m%d`
          mv /boot/initrd-`uname -r`-kdump   /boot/initrd-`uname -r`-kdump_`date +%Y%m%d`
      fi
      ;;

    N | n) 

        echo "ok,good bye"
        exit 1
        ;; 

        *) 

        echo "error choice"
        exit 1
        ;; 
 esac


#######################################################
#   change kdump config and restart kdump service     #
#######################################################

change_restart(){
      if [ $SYSVERSION = '1' ];then
          sed -i 's/^net/#net/g'   /etc/kdump.conf
          sed -i '/^path/a\net 192.168.14.12:/lv_kdump'  /etc/kdump.conf
          sed -i 's/^path/#path/g'   /etc/kdump.conf
          echo -e '\n Now you kdump path is:\n'
          cat /etc/kdump.conf|grep '^path\|^net'
      elif [ $SYSVERSION = '2' ];then
          sed -i '/^KDUMP_SAVEDIR/c\KDUMP_SAVEDIR="nfs://192.168.14.12/lv_kdump"' /etc/sysconfig/kdump
          echo -e '\n Now you kdump path is:\n'
          cat /etc/sysconfig/kdump|grep ^KDUMP_SAVEDIR
      fi 

}

read  -p "Are you sure chaged the kdump path,and restart kdump service now [Y/N]?" answer 


case $answer in

    Y | y)
 
      change_restart
      echo -e '\n Kdump config file is chaned,Now i will restart service .\n'
      if [ $SYSVERSION = '1' ];then
          /etc/init.d/kdump restart
      elif [ $SYSVERSION = '2' ];then
          rckdump restart
      fi
      ;;

    N | n)

      echo "Bye,kdump img cann't generate if you don't restart kdump service"
      exit 1
      ;;

        *)

     echo "error choice"
     exit 1
     ;;
 esac

#######################################################
#        Verification kdump img rebuild               #
#######################################################

kcount=`ls -l /boot|grep kdump|wc -l`
if [ $kcount != 0 ];then
      echo -e '\n Now I will be list the KDUMP IMG \n'
else
    echo 'Not find kdump img in /boot,Please recheck manual'
fi
ls -l /boot |grep kdump 

