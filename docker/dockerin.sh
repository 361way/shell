#!/bin/bash
# 20171207 by yangbk <itybku@139.com>
# mysite: www.361way.com
# desc: install docker host script
# ansible sqdocker -S -R root  -m script -a /root/ybk/dockerin.sh

source /etc/profile

sysctlconf ()
{
	cp /etc/sysctl.conf  /etc/sysctl.conf.`date +%Y%m%d`
	sed -i '/^net.ipv4.conf.all.arp_ignore/ s/net/#net/g'  /etc/sysctl.conf
	sed -i '/^net.ipv4.conf.default.arp_ignore/ s/net/#net/g' /etc/sysctl.conf
	echo '##  Add for docker ##' >>/etc/sysctl.conf
	echo 'net.ipv4.conf.all.arp_ignore = 0' >>/etc/sysctl.conf
	echo 'net.ipv4.conf.default.arp_ignore = 0' >>/etc/sysctl.conf
	sysctl -p -q
}

installdocker ()
{
	notes=`python -c "print '*'*70"`
	echo -e "$notes\n\tGet docker imager and install,please wait moment!\n$notes"
	cd /home/cmreadwh
	wget http://192.168.1.100/docker.tar.gz -q
	tar zxf docker.tar.gz
	cp -r docker-repo-13.1 /tmp
	cd /etc/yum.repos.d/ && rm -rf *.repo && cp /tmp/docker-repo-13.1/docker1.13.1.repo .
	yum install docker-engine -y -q
	echo -e "$notes\n\tThe following packages is installed!\n$notes"
	rpm -qa|grep docker-engine 
}

startdocker ()
{
	sed -i '/^ExecStart=/ c\ExecStart=/usr/bin/dockerd -g /data/docker --mtu 1400 --insecure-registry 0.0.0.0/0' /lib/systemd/system/docker.service
	systemctl daemon-reload
	systemctl start docker
	systemctl enable docker
}

loadimage ()
{
	if [ -d /data/docker/ ];then
		notes=`python -c "print '*'*70"`
		echo -e "$notes\n\tStart to install docker image!\n$notes"
		cd /home/cmreadwh/base-images/ && sh load-images.sh 
		systemctl stop firewalld
		systemctl disable firewalld
	else
		echo '/data/docker/  not exist,please check your config!'
	fi
}


adduser () 
{
	id "migu_mrk" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo 'migu_mrk exist in system!'
		chage -M 99999 migu_mrk
	else
		/usr/sbin/useradd migu_mrk -g docker 
		echo 'qwer1234!' |passwd --stdin migu_mrk
		chage -M 99999 migu_mrk
	fi
}


main () 
{
	count=`ps auxf|grep docker[d]|wc -l`
	if [[ $count -ge 1 ]]; then
		echo 'Docker process is running ,Please run command "ps auxf|grep docker" check……'
	else
		sysctlconf
		installdocker
		startdocker
		loadimage
		adduser
		ipaddr=`/sbin/ifconfig |grep '10.125'|awk '{print $2}'`
		if [[ -n $ipaddr ]]; then
			docker run -e CATTLE_AGENT_IP="$ipaddr"  --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher index.youruncloud.com/appsoar/agent:v2.2.0 http://10.125.14.12/v1/scripts/AFC8A506223322BCF379:1483142400000:eDIYCa9LtaY6gtzpGp39l2cIdc
		fi
	fi
}

main

