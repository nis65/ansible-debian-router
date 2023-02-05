
# vlanifs

## Variable

**vlanifs** should be specified in `host_vars` as it contains interface names and IP adresses. There are no `defaults`.

`vlanifs` is a list of dicts, each dict configures a vlan interface. This example configures vlan `700` on top of `br0`:


```
vlanifs:
  - number: "700"
    baseif: "br0"
    v4info:
      address: 172.27.0.1
      netmask: 255.255.255.0
      broadcast: 172.27.0.255
    v6info:
      address: 2001:db8:1234:6f1::1/64
```

creates `/etc/network/interfaces.d/vlanifs` with the following content:

```
auto br0.700
iface br0.700 inet static
    address 172.27.0.1
    netmask 255.255.255.0
    broadcast 172.27.0.255

iface br0.500 inet6 static
    address 2001:db8:1234:6f1::1/64

```

## Implementation notes

The playbook restarts an already running vlan interface (`ifdown`/`ifup`) when the configuration file needed a rewrite. This should probably be implemented as handler.

Cleanup when renaming/deleting vlans is not tested. You have been warned.

