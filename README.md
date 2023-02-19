# ansible-debian-router
I am using a debian based firewall as home router since
decades. The first thing I do to the connection device received
from my internet provider is to switch it into plain bridge mode
so that signal conversion only is done by that device. 
Then I connect my debian router so that all routing/filtering 
is done there - fully under my control. I am using hardware from
`pcengines.ch`. I started with WRAP, used ALIX and now
it is an [APU2](https://pcengines.ch/apu2.htm).

Instead of updating and redoing lots of detailed documentation, I decided
to automate my experience into ansible code. The new ansible
managed debian bullseye router is in production since January 2nd 2023.

The goals of this project were:
* do a (functionally equivalent) lifecycle, i.e. sidegrade from stretch to bullseye.
* switch from iptables to native nftables.
* full IPv4 and IPv6 support.
* automate the installation and configuration with ansible.
* all important parameters needed to describe the target system should be in one place. This helps managing the configuration and eases testing.
* practise ansible and nftables.

The implemented roles are very specific to my personal use case. I wanted
to keep the roles as simple as possible, i.e. propagate application configuration
options to ansible variables only when I need them. Fully generic roles are nice,
but overcomplicate the code and make test coverage very hard.

Every role uses only its own parameters. This creates some redundancy
in the variables, i.e. a DHCP range you assign using a `dnsmasq` 
variable must match the ip address of an interface (assigned using 
a `bridges`  or `vlanifs` variable). But it keeps the roles as independent
of each other as possible.

There is no validation on the parameters at all. You can easily
break the system with one wrong configuration setting. You have to 
know what you are doing.

**WARNING**: I managed to lock me out at least once during development, so always
have a console access ready to save you from shooting yourself in the foot.

## My home router
* debian bullseye, interfaces managed with `ifupdown` (not `systemd`)
* 3 physical interfaces: enp1s0, enp2s0, enp3s0
* 4 logical interfaces
   * enp1s0: upstream interface
   * br0: downstream, built from enp2s0 and enp3s0
   * br0.XXX on top of br0 (e.g. br0.200)
   * tun0: the openvpn interface
* nftables for packet filtering/masquerading
* dnsmasq for dns/dhcp
* unifi software and hardware, hardware managed on br0, WLAN client traffic on tagged VLAN 
* openvpn with client specific access configuration (both vpn and nft)

### ansible vs manual

This is what I setup manually:

* Enable ansible to manage the system:
   * Install debian bullseye (minimal)
   * Configure the upstream interface with IPv4 DHCP
   * Configure passwordless login as root.
* The following files are used by the running system, but **not** touched by ansible:
   * `/etc/hosts` (for local hostnames that are not learned by dnsmasq over dhcp)
   * `/etc/network/interfaces` (lo and IPv4 DHCP config of the upstream interface)
   * `/etc/crontab` (if you need this)

All other configuration is done by ansible.

### Wishlist

* asterisk

## Roles

All roles fully support both IPv4 and IPv6. In some places, IPv6 is optional.

### Uplink IPv6

This playbook does not touch the **IPv4** configuration of the **uplink** interface,
as at least one interface must work to be able to apply ansible at all. But: 

* **upv6if**: configures IPv6 with (or without) subnet delegation on the uplink interface.

### Virtual interfaces

I just need one bridge and one vlan interface, but both roles support
the creation of multiple bridges or multiple vlan interfaces:

* **bridges**: configure bridges on top of other interfaces
* **vlanifs**: configure vlans on top of other interfaces

### base network infrastructure: packet filter, routing, dns, dhcp

* **nft**: install some configuration files to configure
packet filtering on your router. `nftables` is configured natively,
no `firewalld` or other framework.  It features a simple file drop in
mechanism so that other roles can add additional settings files
without interfering with the main config file or with each other. The
`nft` role itself makes use of that drop in mechanism to configure some "always open" ports.

* **fail2ban**: enables fail2ban with nftables, ssh and openvpn are monitored and acted upon.

* **routing**: enables routing.

* **avahi** enables mDNS forwarding between selected subnets.

* **igmpproxy**: UNTESTED. I thought I need this, but I was wrong.

* **dnsmasq**: installs and configures `dnsmasq` providing both
a dhcp and dns server for the downstream interfaces.
Provides a `nft` drop in file.

### applications: openvpn, unifi

* **openvpn**: only the server part. certificate management is expected to be done externally.
As I wanted to replace a predecessor system, all crypto material was present already and to be migrated from there. Extensive nft drop in file. Individual client configuration for both openvpn and nftables.
* **afraid**: needed to find your openvpn server from anywhere in the internet (dyndns alternative).
* **unifi**: Installs the unifi software and provides some `nft` rules.

## Variables

The variables of the roles are classified into two types:

* *host_vars*: All settings that are likely to be different from router to router, e.g. `host_vars/mimas_dev.yml`:
  * ip adresses (renumbering of all networks should be possible by changing host_vars only)
  * virtual interface configuration (bridges, vlans)
  * openvpn client specific configuration and nft rules
* *defaults*: Settings that are unlikely to be changed but it still nice to have them parametrized.
  * all in `roles/*/defaults/main.yml`

## usage

* Host must be reachable via ssh (see manual setup above).
* Run it with `ansible-playbook router.yml --diff -u root -i inventory`
