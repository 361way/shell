#!/bin/sh
echo Kdump Helper is starting to configure kdump service

#kexec-tools checking
rpm -q kexec-tools > /dev/null
if [ $? -ne 0 ]
then 
	echo "kexec-tools no found, please run command yum install kexec-tools to install it"
	exit 1
fi

mem_total=`free -g |awk 'NR==2 {print $2 }'`
echo Your total memroy is $mem_total G
 
#      RHEL5 crashkernel compute
#       crashkernel=memory@offset
#
#		+---------------------------------------+
#		| RAM       | crashkernel | crashkernel |
#		| size      | memory      | offset      |
#		|-----------+-------------+-------------|
#		|  0 - 2G   | 128M        | 16          |
#		| 2G - 6G   | 256M        | 24          |
#		| 6G - 8G   | 512M        | 16          |
#		| 8G - 24G  | 768M        | 32          |
#		+---------------------------------------+
#   	*/    
compute_rhel5_crash_kernel ()
{
	reserved_memory=128
	offset=16
    mem_size=$1
	if [ $mem_size -le 2 ] 
	then
		reserved_memory=128
		offset=16
	elif [ $mem_size -le 6 ]
	then 
		reserved_memory=256
		offset=24
	elif [ $mem_size -le 8 ]
	then
		reserved_memory=512
		offset=16
    else
		reserved_memory=758
		offset=16
    fi
	echo "$reserved_memory"M@"$offset"M
}

#     RHEL6 crashkernel compute
# 	/*
#       https://access.redhat.com/site/solutions/59432
#
#		ram size	crashkernel parameter	ram / crashkernel factor
#		>0GB			  128MB							15
#		>2GB			  256MB							23
#		>6GB			  512MB							15
#		>8GB			  768MB							31
 #   	*/
compute_rhel6_crash_kernel ()
{
	reserved_memory=128
    mem_size=$1
	if [ $mem_size -le 2 ] 
	then
		reserved_memory=128
	elif [ $mem_size -le 6 ]
	then 
		reserved_memory=256
	elif [ $mem_size -le 8 ]
	then
		reserved_memory=512
    else
		reserved_memory=758
    fi
	echo "$reserved_memory"M
}

#backup grub.conf
grub_conf=/boot/grub/grub.conf
grub_conf_bak=/boot/grub/grub.conf.kdump_`date +%y%m%d`

grub2_conf=/boot/grub2/grub.conf
grub2_conf_bak=/boot/grub2/grub.conf.kdump_`date +%y%m%d`

ufi_conf=/boot/efi/EFI/centos/grub.conf
ufi_conf_bak=/boot/efi/EFI/centos/grub.conf.kdump_`date +%y%m%d`

if [  -f $grub_conf ] ;then
	cp $grub_conf $grub_conf_bak
	echo backup $grub_conf to $grub_conf_bak
elif [  -f $grub2_conf ] ;then
	cp $grub2_conf $grub2_conf_bak
	echo backup $grub2_conf to $grub2_conf_bak
else
	cp $ufi_conf $ufi_conf_bak
	echo backup $ufi_conf to $ufi_conf_bak
fi

kernel_version=`uname -r|awk -F"-" '{print $1}'`
#you can add so many  kernel version in there when your system use it 
if [ $kernel_version == "2.6.32" ]
then
	crashkernel_para=`compute_rhel6_crash_kernel $mem_total `
	echo RHEL6 detected, kernel version: `uname -r`
elif [ $kernel_version == "2.6.18" ]
then
	crashkernel_para=`compute_rhel5_crash_kernel $mem_total `
	echo RHEL5 detected kernel version: `uname -r`
fi

echo crashkernel=$crashkernel_para is set in $grub_conf
grubby --update-kernel=DEFAULT --args=crashkernel=$crashkernel_para

#backup kdump.conf
kdump_conf=/etc/kdump.conf
kdump_conf_bak=/etc/kdump.conf.`date +%y%m%d`

if [ ! -f $kdump_conf_bak ]
then
	cp $kdump_conf $kdump_conf_bak
	echo backup $kdump_conf $kdump_conf_bak
fi

sed -i '/^path/ s/path/#path/g' $kdump_conf
sed -i '/^net/ s/net/#net/g' $kdump_conf
sed -i '/^raw/ s/raw/#raw/g' $kdump_conf
sed -i '/^ext/ s/ext/#ext/g' $kdump_conf

dump_path=/var/crash

echo path $dump_path >> $kdump_conf

dump_level=31
sed -i 's/^core_collector makedumpfile/#core_collector makedumpfile/g' $kdump_conf
echo core_collector makedumpfile -c --message-level 1 -d $dump_level >> $kdump_conf

sed -i '/^default/ s/default/#default/g' $kdump_conf

echo 'default reboot' >>  $kdump_conf

#enable kdump service
echo chkconfig kdumpservice on for 3 and 5 run levels
chkconfig kdump on --level 35
chkconfig --list|grep kdump

echo Starting to Configure extra diagnostic opstions

#sysctl

sysctl_conf=/etc/sysctl.conf
sysctl_conf_bak=/etc/sysctl.conf.`date +%y%m%d`

if [ ! -f $sysctl_conf_bak ]
then
	cp $sysctl_conf $sysctl_conf_bak
	echo backup $sysctl_conf to $sysctl_conf_bak
fi

#server hang
sed -i '/^kernel.sysrq/ s/kernel/#kernel/g ' $sysctl_conf 
echo >> $sysctl_conf
echo '#Panic on sysrq and nmi button, magic button alt+printscreen+c or nmi button could be pressed to collect a vmcore' >> $sysctl_conf
echo '#Added by kdumphelper, more information about it can be found in solution below' >> $sysctl_conf
echo '#https://access.redhat.com/site/solutions/2023' >> $sysctl_conf
echo 'kernel.sysrq=1' >> $sysctl_conf
echo 'kernel.sysrq=1 set in /etc/sysctl.conf'
echo '#https://access.redhat.com/site/solutions/125103' >> $sysctl_conf
echo 'kernel.unknown_nmi_panic=1' >> $sysctl_conf
echo 'kernel.unknown_nmi_panic=1  set in /etc/sysctl.conf'

#softlockup
sed -i '/^kernel.softlockup_panic/ s/kernel/#kernel/g ' $sysctl_conf 
echo >> $sysctl_conf
echo '#Panic on soft lockups.' >> $sysctl_conf
echo '#Added by kdumphelper, more information about it can be found in solution below' >> $sysctl_conf
echo '#https://access.redhat.com/site/solutions/19541' >> $sysctl_conf
echo 'kernel.softlockup_panic=1' >> $sysctl_conf
echo 'kernel.softlockup_panic=1 set in /etc/sysctl.conf'

