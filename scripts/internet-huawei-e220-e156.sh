#!/bin/sh

while true
do
  killall -HUP pppd
  sleep 1
  date

  E220=/dev/serial/by-id/usb-HUA_WEI_Huawei_Mobile-if00-port0
  E156=/dev/serial/by-id/usb-HUAWEI_Technology_HUAWEI_Mobile-if00-port0

  if [ -L $E220 ]
  then
    # E220 won't complain if already PIN-unlocked
    #
    PORT=$E220
    CPIN="AT+CPIN=7830"
  else
    # E156 should be unlocked before invoking this script
    #
    PORT=$E156
    CPIN="AT+CPIN?"
  fi

  # COPS replies either "3 Italy" or "3 ITA"; trying to catch both:
  #
  /usr/sbin/pppd $PORT 921600 crtscts nodetach defaultroute lcp-echo-failure 8 lcp-echo-interval 3600 connect '/usr/sbin/chat -t 6 -s -v "" ATZ OK '"$CPIN"' OK AT+CGDCONT=1,\"IP\",\"tre.it\",\"\",0,0 OK AT+CREG=1 OK AT+CSQ OK AT+COPS? +COPS:\ 0,0,\"3\ I "" OK AT+CREG? +CREG:\ 1, "" OK ATD*99***1# CONNECT \d\c'

done

