#!/bin/bash


source /root/infra_init/color


ip=`ip a| grep -P 'ens[\d]{1,5}|eth[\d]{1,3}' |grep inet |awk '{print $2}'`
cpu=`cat /proc/cpuinfo  |grep processor |wc -l`
mem=`free -h |grep Mem |awk '{print $2 }'`
ns1=`cat /etc/resolv.conf |grep nameserver | sed -n '1p' |awk '{print $2}'`
ns2=`cat /etc/resolv.conf |grep nameserver | sed -n '2p' |awk '{print $2}'`
host=`hostname`
date=`date`
disk=`df -h |sed -n '2p' |awk '{print $2}'`


echo ""
echo "Please confirm the following information"
echo ""


echo -e  "1. Hostname  :  \c " ; green $(hostname)

echo -e  "2. Local IP Address :  \c " ; green $ip 

echo -e  "3. CPU Cores :  \c " ; green $cpu

echo -e  "4. Mem Size :  \c " ; green $mem

echo -e  "5. Disk Size : \c " ; green $disk

echo -e  "6. Master DNS Server :  \c " ; green $ns1 
echo -e  "   Slave  DNS Server :  \c " ; green $ns2 

echo -e  "7. Clock :  \c " ; green "$(date)"

echo -e  "8. Testing ping ...." 

function testping(){

ping -q -c2 $1 > /dev/null


	if [[ $? -eq "0" ]];then 

		echo -e  "ping to $1 : \c" ; green "OK"

	else 

		echo -e  "ping to $1 : \c" ; bred "Failed"

	fi
		}



testping 192.168.101.254
testping 192.168.89.254
testping 8.8.8.8
