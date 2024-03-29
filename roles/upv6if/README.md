
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
* adjust route to reach the downstream subnet behind a downstream router
* fully renumber the downstream router and subnet

Therefore, I decided against dynamic renumbering on the debian router
in favor of defining that renumbering is the responsibility of the
ansible playbook.  If I ever should lose "my" IPv6 subnet and get a
new one, I'll have to adjust a few ansible variables and rerun
the playbook.

The last two tasks of the role actually check whether prefix delegation 
worked by comparing the value of `upv6if_expected_delegation` against
the dynamically maintained status file of `dhclient -6 ...` on the target. So 
whenever the prefix delegation should change, the playbook will abort until
the configuration matches reality.

## Variables

There are only very use case specific variables to set, so everything should go to `host_vars`:

```
upv6if_expected_delegation: "2001:db8:1234:6f0::/60"

upv6if_iface: enp1s0
upv6if_mode: dhcp
upv6if_configlines:
  - "request_prefix 1"
  - "accept_ra 2"
```

## Implementation notes

The task *check delegated subnet* uses `ansible.builtin.lineinfile` to check for
the expected line. This looks like the role would overwrite the leases file when
running the playbook without `--check`. But the task level `check_mode: yes` makes 
ansible execute that task in check mode always. So the leases file is never
changed by that role.

