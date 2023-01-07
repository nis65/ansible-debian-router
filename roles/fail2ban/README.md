
# fail2ban

This role enables fail2ban

## Variables

Set in `defaults`: 

`fail2ban_openvpn_retry` sets the number of failed openvpn connections from a certain ip until fail2ban locks the port for that ip

## Implementation notes

* the debian defaults enable ssh already - this is the only thing we really need.
* the `jail.local` switches the fail2ban config from iptables to nftables
