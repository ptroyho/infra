#!/bin/bash
#ntpdate
yum -y install ntpdate
/usr/sbin/ntpdate time.stdtime.gov.tw

#auto reboot ntpdate
chmod +x /etc/rc.d/rc.local
echo "sudo ntpdate time.stdtime.gov.tw"  >> /etc/rc.d/rc.local

#ntpdate one hour
echo "0 * * * * root (/usr/sbin/ntpdate time.stdtime.gov.tw && /sbin/hwclock -w) &> /dev/null" >> /etc/crontab
