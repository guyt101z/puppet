#!/bin/bash
#Check status of FreeSWITCH SIP interfaces
#Doesn't restart FreeSWITCH if WAN or VPN interfaces are down

RHIZO_SCRIPT="/home/rhizomatica/bin"
. $RHIZO_SCRIPT/vars.sh

LOGFILE="/var/log/monitor_fs.log"

IFS=
FS_STATUS="$(fs_cli -x 'sofia status')"

if !(echo $FS_STATUS | egrep -q "internal.*172.16.0.1"); then
	logc "Missing internal profile! Restarting Profile";
	fs_cli -x "sofia profile internal stop"
	sleep 10
	fs_cli -x "sofia profile internal start"
fi

if !(echo $FS_STATUS | grep -q "external::provider") && (ping -qc 5 8.8.8.8 > /dev/null); then
	logc "Missing external provider! Restarting Profile";
	fs_cli -x "sofia profile external stop"
	sleep 10
	fs_cli -x "sofia profile external start"
fi

if !(echo $FS_STATUS | grep -q "internalvpn") && (ping -qc 5 10.23.0.2 > /dev/null); then
	logc "Missing internal VPN. Restarting FreeSWITCH profile";
	fs_cli -x "sofia profile internalvpn stop"
	sleep 10
	fs_cli -x "sofia profile internalvpn start"
fi
