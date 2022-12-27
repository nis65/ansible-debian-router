
# dnsmasq

dnsmasq is used as both DNS and DHCP Server. 

## Variables

To be set in `host_vars`:

* `dnsmasq_except_interface`: you don't want dnsmasq to serve the upstream interface, should be set to the same value as `nft_upstream_interface`. While DHCP is usually not desired on the vpn, DNS is. See the `nft` rules below.

* `dnsmasq_dhcp_search_domain_names`: The domains you want to suggest the DHCP clients to search for.

* `dnsmasq_other_servers`: I run a system with an internal domain and separate networks. This makes `dnsmasq` forward queries for such domains to the defined name servers.

* `dnsmasq_dhcp_staticips_source`: Only copied to the target host when not present there. Is basically a reminder that this file exists but can be managed on the target host directly (does that make sense?). I manage e.g. the IP adress of my printer there.

* `dnsmasq_dhcp_ranges`: the ranges you want `dnsmasq` to assign to the network clients. The ranges must match the IP adresses you have assigend to your downstream interfaces.

Set in `defaults`:

`nft_dnsmasq` is a list of dicts, each dict has a name and a list of ports. The name is used to construct the name of the set where the ports go to. This is exactly the same logic as used in the `nft` role. The following default allows incoming DNS requests:

```
nft_dnsmasq:
  - name: input_downstream_tcp
    ports:
      - "53"
  - name: input_downstream_udp
    ports:
      - "53"
```

`dnsmasq_flags` is a list of config flags for dnsmasq, the default logs both dns queries and dhcp communications:

```
dnsmasq_flags:
  - log-queries
  - log-dhcp
```

## Implementation notes

The firewall rules are implemented in `dnsmasq.nft.j2`. The rules for DNS traffic are using the rules in `/etc/nftables.conf` and extend the respective port sets.  The rules to accept DCHP requests and send replies are implemented as stateless `apprules`
