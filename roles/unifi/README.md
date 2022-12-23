
# unifi



## Variable

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
## Set input_downstream_tcp_ports
add element inet filter input_downstream_tcp_ports { 8443 }

## Set input_mgmt_tcp_ports
add element inet filter input_mgmt_tcp_ports { 8080 }

## Set input_mgmt_udp_ports
add element inet filter input_mgmt_udp_ports { 3478, 10001 }
```

which will turn up in `nft list rules`:

```
        set input_downstream_tcp_ports {
                type inet_service
                flags interval
                elements = { 8443 }
        }

```

```
        set input_mgmt_tcp_ports {
                type inet_service
                flags interval
                elements = { 8080 }
        }

```

```
        set input_mgmt_udp_ports {
                type inet_service
                flags interval
                elements = { 3478, 10001 }
        }
```


## Implementation notes

This role is somewhat slow as it enforces an `apt-get update` in the last step because the previous tasks add new repos and keys. Maybe this should only be done if these pre tasks acutally changed something.

The unifi stuff in its current state is untested as I don't have spare unifi hardware for testing right now.


