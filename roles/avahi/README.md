
# avahi

This role installs and configures avahi-daemon. The nft drop in file
opens two udp ports on the avahi-interfaces:

* 5353: mDNS
* 57621: spotify


## Variables

Only `host_vars`:

~~~
avahi_interfaces:
  - br0
  - br0.700
~~~

## Implementation notes

I just need this to be enable my mobile on WLAN (br0.700) to automatically
detect a spotify connect speaker on the LAN (br0).
