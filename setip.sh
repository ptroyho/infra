#!/bin/bash

source /root/infra_init/color

#ifcfg=`echo "/root/infra_init/ifcfg-ens192"`
#set -x 

function bulid_ifcfg() {
cat << EOF  > /etc/sysconfig/network-scripts/ifcfg-$interface
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
NAME=$interface
DEVICE=$interface
ONBOOT=yes
PREFIX=24
IPADDR=
GATEWAY=
EOF
}

echo "The current search interface is as follows : " 
ip link show |grep -v "link" |awk -F ":" '{print $2}'


read -p "Enter interface name : " interface

if [[ $interface == "" ]];then

	echo "Enter your interface name!!! "
	exit 1
else
	bulid_ifcfg	
	ifcfg=`echo "/etc/sysconfig/network-scripts/ifcfg-$interface"`
fi

function check_ip() {
    IP=$1
    VALID_CHECK=$(echo $IP|awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')
    if echo $IP|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$">/dev/null; then
        if [ ${VALID_CHECK:-no} == "yes" ]; then
            echo ""
	fi
    else
	bred "$IP invalid  , format must be xxx.xxx.xxx.xxx"
	exit 1
    fi
}


sed -i '/^IPADDR=*.*$/d' $ifcfg

sed -i '/^GATEWAY=*.*$/d' $ifcfg


read -p "Enter this vm ip subnet ; EX: 89 or 101  :  " subnet

if [[ $subnet -eq "89" ]];then
 
	echo "IPADDR=192.168.89.16" >> $ifcfg

	echo "GATEWAY=192.168.89.254" >> $ifcfg
	
	systemctl restart network

elif [[ $subnet -eq "101" ]];then

 
	echo "IPADDR=192.168.101.16" >> $ifcfg

	echo "GATEWAY=192.168.101.254" >> $ifcfg
	
	systemctl restart network
	
else 
	bred "subnet must be 89 or 101 !!!"
	
	exit 1
fi


function set1() {
lim=0
echo "1.Set IP Address..."
echo ""
read -p "Enter IP Address : "  ip

check_ip $ip

echo "Checking IP...."
echo ""
ping -q -c2 $ip > /dev/null
	if [[ $? -eq "1" ]] ;then 
		green "This IP can be used   ...."
	else
		lim=$(($lim+1))
			if [[ $lim -eq 3 ]] ;then
			bred  "limit 3 times "
			exit 1 
			else
		        bred "IP Address already assigned to else VM , please change another IP and try again "
			set1
			fi
	fi
}

set1

echo ""
echo "2.Setup IP and Gateway now......"
echo ""

sed -i '/^IPADDR=*.*$/d' $ifcfg

sed -i '/^GATEWAY=*.*$/d' $ifcfg

echo "IPADDR=$ip" >> $ifcfg

echo "GATEWAY=192.168.$subnet.254" >> $ifcfg

echo ""
echo "Restarting network ...."
echo ""

service network restart

if [[ $? -eq "0" ]];then

	echo -e "service restart \c" ; green "Success"

else 

	echo -e "service restart \c" ; bred "Faild ,please check network service"
	exit 1
fi


echo ""
echo "3.Setting Hostname...."

echo ""
read -p "Enter Hostname [default: centos]   : " hostname 

if [[ $hostname == "" ]];then 

	hostnamectl set-hostname centos7

else 

	hostnamectl set-hostname $hostname
fi

echo ""

echo "If hostname is  incorrect , please re-login tty !!"

echo "4.Setting DNS Server...."

echo 

cat << NAME > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
NAME

echo "5.Time synchroization...."

ntpdate time.stdtime.gov.tw

echo ""

echo "Setup Completd ......"

echo ""

echo "==========================="

sh /root/infra_init/check.sh


