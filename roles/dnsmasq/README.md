
# dnsmasq

dnsmasq is used as both DNS and DHCP Server. 

## Variables

`nft_dnsmasq` is a list of dicts, each dict has a name and a list of ports. The name is used to construct the name of the set where the ports go to. This is exactly the same logic as used in the `nft` role. So

```
nft_dnsmasq:
  - name: input_downstream_tcp
    ports:
      - "53"
  - name: input_downstream_udp
    ports:
      - "53"
```

creates `/etc/nftables.conf.d/dnsmasq.nft` (logic identical to nft and unifi roles).


## Implementation notes

This role is work in progress. I'll start with dns then will go on to dhcp.



