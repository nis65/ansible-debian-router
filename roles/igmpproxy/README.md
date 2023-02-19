
# igmpproxy

This role installs and configures igmpproxy. 

**DO NOT USE**, untested

## Variables

Only `host_vars, `altnet` not implemented, but would be needed
in a real world scenario probably.

~~~
igmpproxy_interfaces:
  disabled:
    - enp1s0
    - tun0
  upstream:
    - br0
  downstream:
    - br0.500

~~~

## Implementation notes

I implemented this because I thought it would help my mobile
on the `br0.700` VLAN to detect `raspotify` on `br0`. But as
it turns out, the only thing I need is mDNS (`avahi`).

