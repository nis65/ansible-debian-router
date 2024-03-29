
# bridges

## Variables

**bridges** should be specified in `host_vars` as it contains interface names and IP adresses. There are no `defaults`.

`bridges` is a list of dicts, each dict configures a bridge. This example configures one bridge:

```
bridges:
  - name: "br0"
    members:
      - enp2s0
      - enp3s0
    v4info:
      address: 172.30.0.1
      netmask: 255.255.254.0
      broadcast: 172.30.1.255
      routes:
        - target: 10.10.10.0/24
          gw: 172.30.0.134
        - target: 10.10.20.0/24
          gw: 172.30.0.134
    v6info:
      address: 2001:db8:1234:6f0::1/64

```

creates `/etc/network/interfaces.d/bridges` with the following content:

```
# set members of br0 to manual
iface enp2s0 inet manual
iface enp3s0 inet manual
# configure br0
auto br0
iface br0 inet static
    bridge_ports enp2s0 enp3s0
    address 172.30.0.1
    netmask 255.255.254.0
    broadcast 172.30.1.255
    up ip route add 10.10.10.0/24 via 172.30.0.134
    down ip route del 10.10.10.0/24 via 172.30.0.134
    up ip route add 10.10.20.0/24 via 172.30.0.134
    down ip route del 10.10.20.0/24 via 172.30.0.134
iface br0 inet6 static
    bridge_ports enp2s0 enp3s0
    address 2001:db8:1234:6f0::1/64
```


## Implementation notes

**WARNING**: Supplying a route to an gateway that is not on the local network will prevent `ifup` from bringing up `br0` properly. This prevents the network stack from properly booting and you can have strange issues...

The playbook checks the live ip address of an already running bridge and restarts the bridge (`ifdown`/`ifup`) if they don't match to force the new address (or if the `bridges` file was changed).

Cleanup when renaming/deleting bridges, adding/removing routes is not tested. You have been warned.

