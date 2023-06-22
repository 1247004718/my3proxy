#!/bin/bash
##author by dawanjia 1247004718
RED="\033[31m"      # Error message
GREEN="\033[32m"    # Success message
YELLOW="\033[33m"   # Warning message
BLUE="\033[36m"     # Info message
PLAIN='\033[0m'

function ifcmd() {
    if [ $? -ne 0 ]; then
        exit
    fi
}

which wget || yum install -y wget
ifcmd
if [ ! -d /var/log/3proxy/ ]; then
   mkdir -p /var/log/3proxy/
fi

wget -cO  /tmp/3proxy.tar.gz  https://raw.githubusercontent.com/1247004718/my3proxy/master/3proxy.tar.gz --no-check-certificate
ifcmd
wget -cO  /usr/bin/t2proxy  https://raw.githubusercontent.com/1247004718/my3proxy/master/t2proxy --no-check-certificate
ifcmd
chmod +x /usr/bin/t2proxy
tar -xf /tmp/3proxy.tar.gz -C /

echo "
[Unit]
Description=3proxy Proxy Server
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/usr/bin/3proxy /etc/3proxy/3proxy.cfg

[Install]
WantedBy=multi-user.target
" >/lib/systemd/system/3proxy.servicew
w


systemctl daemon-reload && systemctl enable  --now 3proxy && systemctl start 3proxy
ifcmd
IP=`curl -sL -4 ip.sb`
if [[ "$?" != "0" ]]; then
    IP=`curl -sL -6 ip.sb`  
fi
PORT=`cat /etc/3proxy/3proxy.cfg |grep admin|tail -1|cut -d "p" -f 2`
STATUS="未运行"
WEBUSER=admin
WEBPASS=`cat /etc/3proxy/3proxy.cfg |grep admin|head -1|cut -d ":" -f 3`
res=`ss -nutlp|grep -i 3proxy`
if [[ ! -z "$res" ]]; then
       STATUS="正在运行"
fi
echo -e ${GREEN} 3proxy ${STATUS}${PLAIN}
echo -e ${GREEN} 登录链接 http://$IP:$PORT${PLAIN} ${RED}User:$WEBUSER Pass:$WEBPASS${PLAIN}
