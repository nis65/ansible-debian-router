# ansible-debian-router
I am using a debian based firewall on pcengines hardware since 
decades. I started with WRAP, used ALIX and now it is an APU2.

Instead of keeping lots of detailed documentation, I decided
to automate my knowledge into ansible code.

This is **work in progress**. Check current state below.

## Roles

### Virtual interfaces
Two roles to configure bridges and vlan interfaces on top of the physical
ones. If you just want to use your interfaces as is, you won't need to use
these roles:

* **bridges**: configure bridges on top of other interfaces
* **vlanifs**: configure vlans on top of other interfaces

### nftables filter and routing

* **nft**: install some configuration files to configure
the firewall on your router. nftables is configured natively,
no `firewalld` or other framework.  It features a simple file drop in
mechanism so that later roles can add a file with additional settings
without interfering with the core config file or with each other. The
`nft` role makes use of that mechanism to configure some "always open" ports
itself.

* **routing**: enables routing (IPv6 not yet implemented).

* **dnsmasq**: installs and configures `dnsmasq` providing both
a dhcp and dns server for the downstream interfaces.
Provides a `nft` drop in file.

### applications

* **openvpn**: wip: untested, server starts. Provides some `nft` rules.
* **unifi**: wip: untested, server starts, web access ok. Provides some `nft` rules.

### wishlist

* Fail2ban: dynamically ban sources with too many connects within given timeframe
* IPv6
    * DHCPv6 with prefix delegation (if supported from provider)
    * radvd for distributing IPv6 internally
* asterisk server
* ...

## Variables

The variables of the roles are classified into two types:

* *host_vars*: All settings that are likely to be different from router to router, e.g. `host_vars/mimas4.yml`:
  * ip adresses
  * virtual interface configuration (bridges, vlans)
* *defaults*: Settings that are unlikely to be change but it still nice to have them parametrized. These are in `roles/*/defaults/main.yml`

## usage

The ansible code starts when the APU is 
* running debian bullseye 
* reachable over ssh without password 
* Run it with `ansible-playbook router.yml --diff -u root -i inventory`

## FAQ

Why not use some prebuilt open firewall distribution?
* I like to understand what is going on
* I like to stay up to date how things are done "the debian way"
* I want to practice ansible
* I like debian
