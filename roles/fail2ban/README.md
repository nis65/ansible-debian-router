
# fail2ban

This role enables fail2ban. The following jails are established

* `sshd`: enabled by default in debian
* `openvpn`: config created for this role, there is currently no preset openvpn configuration in debian
* `recidive`: There are more and more bots around that know about `fail2ban` and similar frameworks. So the rate of hitting your firewall with login attempts is automatically adjusted to the `fail2ban` settings. `recidive` is the `fail2ban` module that watches its own logfile: If an IP gets banned too often by `fail2ban` application rule, `recidive` detects this and will block the ip (all tcp ports) for a much longer time.

## Variables

Set in `defaults`: 

* `fail2ban_openvpn_retry` sets the number of failed openvpn connections from a certain ip until fail2ban locks the port for that ip
* `fail2ban_recidive_bantime` sets the time an ip is banned by `recidive`
* `fail2ban_recidive_findtime` sets the time repeated retries are considered.

## Implementation notes

* the `jail.local` switches the fail2ban config from iptables to nftables
* the default recidive action (ban all ports) has been adjusted (for nftables integagration only) to block all TCP **and** UDP traffic
* the systemd unit is enhanced to make fail2ban play well together with nftables (see issue [#43](https://github.com/nis65/ansible-debian-router/issues/43) for details)
