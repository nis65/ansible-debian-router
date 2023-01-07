# ansible-debian-router
I am using a debian based firewall on pcengines hardware since 
decades. I started with WRAP, used ALIX and now it is an APU2.

Instead of keeping lots of detailed documentation, I decided
to automate my experience into ansible code. On January 2nd 2023,
I replaced the old manually configured debian stretch apu2 with
the shiny new bullseye ansible managed one.

The goals of this project were:
* do a (functionally equivalent) lifecycle, i.e. sidegrade from stretch to bullseye.
* switch from iptables to native nftables.
* automate the installation and configuration with ansible.
* all important parameters needed to describe the target system should be in one place. This helps managing the configuration and eases testing.
* practise ansible and learn nftables.

The implemented roles are very specific to my personal use case. I wanted
to keep the roles as simple as possible, i.e. define only parameters/configurations
that I need. Fully generic roles are nice, but overcomplicate the code and
make test coverage very hard.

Every role uses only its own parameters. This needs some care when creating
the configuration, i.e. the DHCP ranges you assign to dnsmasq must match the
ip address of the interface you want to run DCHP on.

There is no validation on the parameters at all. It is easily possible
break the system with one wrong configuration setting.
**WARNING**: I managed to lock me out at least once during the development, so always
have a console access ready to save you from shooting yourself in the foot.

## My router
* debian bullseye, interfaces managed with `ifupdown`
* 4 logical interfaces
   * enp1s0: upstream interface
   * br0: downstream, built from enp2s0 and enp3s0
   * br0.XXX on top of br0 (e.g. br0.200)
   * tun0: the openvpn interface
* nftables for packet filtering/masquerading
* dnsmasq for dns/dhcp
* unifi software and hardware, hardware managed on br0, but WLAN client traffic on tagged VLAN
* openvpn with client specific access configuration (both vpn and nft)

### ansible vs manual

This is what I setup manually:

* Enable ansible to manage the system:
   * Install debian bullseye (minimal)
   * Configure the upstream interface with IPv4 DHCP
   * Configure passwordless login as root.
* The following files are used by the running system, but **not** touched by ansible:
   * `/etc/hosts` (for local or vpn hostnames that are not learned by dnsmasq over dhcp)
   * `/etc/network/interfaces` (lo and IPv4 DHCP config of the upstream interface)
   * `/etc/crontab` (if you need this)

All other configuration is done by ansible.

### Wishlist

* Full IPv6 support: upstream interface, bridge, vlan, nft, routing, dnsmasq, openvpn. The poor integration of IPv6 in stretch compared to bullseye was one of my main drivers for this project.
* asterisk

## Roles

### Virtual interfaces
I just need one bridge and one vlan interface, but both roles support
the creation of multiple bridges or multiple vlan interfaces:

* **bridges**: configure bridges on top of other interfaces
* **vlanifs**: configure vlans on top of other interfaces

### base network infrastructure: packet filter, routing, dns, dhcp

* **nft**: install some configuration files to configure
the firewall on your router. nftables is configured natively,
no `firewalld` or other framework.  It features a simple file drop in
mechanism so that later roles can add an additional settings file
without interfering with the core config file or with each other. The
`nft` role itself makes use of that drop in mechanism to configure some "always open" ports.

* **fail2ban**: enables fail2ban with nftables, ssh and openvpn are monitored and acted upon.

* **routing**: enables routing.

* **dnsmasq**: installs and configures `dnsmasq` providing both
a (IPv4) dhcp and dns server for the downstream interfaces.
Provides a `nft` drop in file.

### applications: openvpn, unifi

* **openvpn**: only the server part. certificate management is exptected to be done externally.
As I wanted to replace a predecessor system, all crypto material was to be migrated from the there anyway. Extensive nft drop in file. Individual client configuration (openvpn and nftables).
* **afraid**: needed to find your openvpn server from anywhere in the internet (dyndns alternative).
* **unifi**: Installs the unifi software and provides some `nft` rules.

## Variables

The variables of the roles are classified into two types:

* *host_vars*: All settings that are likely to be different from router to router, e.g. `host_vars/mimas_dev.yml`:
  * ip adresses (renumbering of all networks should be possible by channging host_vars only)
  * virtual interface configuration (bridges, vlans)
  * openvpn client specific configuration and nft rules
* *defaults*: Settings that are unlikely to be changed but it still nice to have them parametrized.
  * all in `roles/*/defaults/main.yml`

## usage

* Host must be reachable via ssh (see manual setup above).
* Run it with `ansible-playbook router.yml --diff -u root -i inventory`
