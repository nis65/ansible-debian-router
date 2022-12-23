# ansible-debian-router
I am using a debian based firewall on pcengines hardware since 
decades. I started with WRAP, used ALIX and now it is an APU2.

Instead of keeping lots of detailed documentation, I decided
to automate my knowledge into ansible code.

This is **work in progress**. Current state:

The following roles are implemented and tested until now:

* **bridges**: configure bridges on top of other interfaces
* **vlanifs**: configure vlans on top of other interfaces

These first two roles are completely independent of each other, depending on
your network architecture you might need to execute the roles in a different
order than documented here.

* **nft**: configure the nftables firewall. Allows later packages to add their own nftables rules
* **unifi**: add nft rules and install unifi software

The following is planned (yes, I love networking):

* openvpn server
* DHCPv6 with prefix delegation (if supported from provider)
* radvd for distributing IPv6 internally
* asterisk server
* ...

The ansible code starts when the APU is 
* running debian bullseye 
* reachable over ssh without password 
* Run it with `ansible-playbook router.yml --diff -u root -i inventory`

Why not use some prebuilt open firewall distribution?
* I like to understand what is going on
* I like to stay up to date how things are done "the debian way"
* I want to practice ansible
* I like debian


