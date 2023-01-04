
# fail2ban

This role enables fail2ban

## Variables

none

## Implementation notes

* the debian defaults enable ssh already - this is the only thing we really need.
* the `jail.local` switches the fail2ban config from iptables to nftables
