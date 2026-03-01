#!/bin/bash
STATUS=/tmp/latest_afraid_update.txt
STATUSV6=/tmp/latest_afraid_update_v6.txt

DEFAULTS=/etc/default/afraid
. $DEFAULTS

EXTIF={{ afraid_external_vpn_interface }}
ALIAS={{ afraid_domain_name }}

localip4=`LANG=C ip -4 a show dev $EXTIF | sed -ne "s|^ *inet \([\.0-9]*\)/.*$|\1|p"`
dnsip4=`host -t a $ALIAS | awk '{ print $4 }'`

if [[ "$localip4" == "$dnsip4" ]]
then
  true
else
  echo "`date` Local IPv4: $localip4, DNS IPv4: $dnsip4" > $STATUS
  if [[ -z "$UPDATEURL" ]]
  then 
    echo "UPDATEURL is empty. Not updating, local check only" | tee -a $STATUS
  else
    wget -q -O - "$UPDATEURL" >> $STATUS
  fi
  echo "`date` Update done." >> $STATUS
fi

localip6=`LANG=C ip -6 a show dev $EXTIF | sed -ne "s|^ *inet6 \([:0-9a-f]*\)/.*$|\1|p" | egrep -v "^fe80" | head -1`
dnsip6=`host -t aaaa $ALIAS | awk '{ print $5 }'`

if [[ "$localip6" == "$dnsip6" ]]
then
  true
else
  echo "`date` Local IPv6: $localip6, DNS IPv6: $dnsip6" > $STATUSV6
  if [[ -z "$UPDATEV6URL" ]]
  then
    echo "UPDATEV6URL is empty. Not updating, local check only" | tee -a $STATUSV6
  else
    wget -q -6 -O - "$UPDATEV6URL" >> $STATUSV6
  fi
  echo "`date` Update done." >> $STATUSV6
fi
