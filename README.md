# ansible-debian-router
I am using a debian based firewall on pcengines hardware since 
decades. I started with WRAP, used ALIX and now it is an APU2.

Instead of keeping lots of detailed documentation, I decided
to automate my knowledge into ansible code.

**WARNING**: This is very early work in progress. **do not use!**

The most delicate part of my installation turned out to 
be the unifi management software, it currently keeps me 
from updating the base os. So **unifi** will be the first 
role to come to live, 

The following will be needed too (yes, I love networking):

* **bridge** bridging two or more APU interfaces
* VLAN for the unifi WLAN client traffic
* routing/firewalling with multiple interfaces
* DHCPv6 with prefix delegation (if supported from provider)
* radvd for distributing IPv6 internally
* openvpn server
* asterisk server
* ...

The ansible code starts when the APU is 
* running debian bullseye 
* reachable over ssh without password 

Why not use some prebuilt open firewall distribution?
* I like to understand what is going on
* I like to stay up to date how things are done "the debian way"
* I want to practice ansible
* I like debian

