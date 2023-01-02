#!/bin/bash
STATUS=/tmp/last_update_afraid.txt

DEFAULTS=/etc/default/afraid
. $DEFAULTS

EXTIF={{ afraid_external_vpn_interface }}
ALIAS={{ afraid_alias }}

localip4=`LANG=C ip -4 a show dev $EXTIF | sed -ne "s|^ *inet \([\.0-9]*\)/.*$|\1|p"`
dnsip4=`host -t a $ALIAS | awk '{ print $4}'`

if [[ "$localip4" == "$dnsip4" ]]
then
  true
else
  echo "`date` Local IP: $localip4, DNS IP: $dnsip4" > $STATUS
  if [[ -z "$UPDATEURL" ]]
  then 
    echo "UPDATEURL is empty. Not updating, local echeck only" | tee -a $STATUS
  else
    wget -q -O - "$UPDATEURL" >> $STATUS
  fi
  echo "`date` Update done." >> $STATUS
fi

