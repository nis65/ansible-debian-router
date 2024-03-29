
# unifi


## Variable

I did not find any reason to have host specific configuration, so the only variable is a default one.

`nft_unifi` is a list of dicts, each dict has a name and a list of ports. The name is used to construct the name of the set where the ports go to. This is exactly the same logic as used in the `nft` role. So

```
nft_unifi:
  - name: input_downstream_tcp
    ports:
      - "8443"
  - name: input_mgmt_tcp
    ports:
      - "8080"
  - name: input_mgmt_udp
    ports:
      - "3478, 10001"
```

creates `/etc/nftables.conf.d/unifi.nft` with the following content:

```
## Set input_downstream_tcp_dports
add element inet filter input_downstream_tcp_dports { 8443 }

## Set input_mgmt_tcp_dports
add element inet filter input_mgmt_tcp_dports { 8080 }

## Set input_mgmt_udp_dports
add element inet filter input_mgmt_udp_dports { 3478, 10001 }
```

which will turn up in `nft list rules`:

```
        set input_downstream_tcp_dports {
                type inet_service
                flags interval
                elements = { 8443 }
        }

```

```
        set input_mgmt_tcp_dports {
                type inet_service
                flags interval
                elements = { 8080 }
        }

```

```
        set input_mgmt_udp_dports {
                type inet_service
                flags interval
                elements = { 3478, 10001 }
        }
```


## Implementation notes

This role is somewhat slow as it enforces an `apt-get update` in the last step because the previous tasks add new repos and keys. Maybe this should only be done if these pre tasks acutally changed something.
