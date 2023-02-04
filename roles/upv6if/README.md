
# upv6if

This role configures IPv6 on the uplink interface. My use case is:

* IPv6 address is assigned from provider via DHCPv6
* Provider supports prefix delegation, but
  * a /60 is delegated, no longer/shorter prefixes available
  * as long DHCPv6 refreshes the lease and delegation regularly enough, 
    it remains the same.

In theory, it would be nice to automatically assign IPv6 addresses 
to the various interfaces based on the prefix delegated. 

However, this would need live automation (i.e. dynamically on the router) 
of a lot of steps and some are even on a remote node:

* assign IPv6 addresses to all local interfaces including openvpn/`ppp0`.
* adjust route to reach the local subnet behind a downstream router
* fully renumber the downstream router

Therefore, I decided against dynamic renumbering on the debian router
in favor of defining that renumbering is the responsibility of the 
ansible playbook.  If I ever should lose "my" IPv6 subnet and get a 
new one, I'll have to adjust one single ansible variable and rerun 
the playbook.

## Variables

There are only very use case specific variables to set, so everything should go to `host_vars`:

```
upv6if_iface: enp1s0
upv6if_mode: dhcp
upv6if_configlines:
  - "request_prefix 1"
  - "accept_ra 2"
```

## Implementation notes

The script is currently started every 5 minutes. Your mileage may vary. See the result of the
latest update in `/tmp/latest_afraid_update.txt`.
