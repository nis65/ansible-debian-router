
# nft

This role directly configures `nftables` via configuration files. In order to make the file structure
easily extendable, I am using the *syntax of calling the nft binary several times, but in an atomic fashion*,
see [here](https://wiki.nftables.org/wiki-nftables/index.php/Scripting#File_formats).

The base architecture for nftables is as follows:

* One `filter` table with three chains: `input`, `output`, `forward`. This is functionally equivalent to the old `iptables` concept
* Each chain has policy `drop`, so if you don't explicitly allow traffic, it will be blocked
* Each rule has a counter associated with to check if the rules get actually used
* The end of each chain has a `log` rule, so all blocked packets are logged
* Each chain has some default `accept` filters:
  * localhost (on input/output) is always allowed
  * ICMP/ICMPv6 is always allowed (you might want to be more strict on that)
  * **TODO** document/test igmp
  * return packets are always allowed (i.e. they can be associated with an earlier packet, stateful!)
  * DHCPrequests from the upstream interface (and its replies) are always allowed (stateless)
* there is a nftables [set](https://wiki.nftables.org/wiki-nftables/index.php/Sets) for various interfaces and interfaces groups, defining the allowed destinations tcp/udp ports for a certain interface group:
  * `input_tcp_ports`: ports that are open on **all** interfaces
  * `input_downstream_tcp_ports`: ports that are open all interfaces except the upstream interface
  * `input_mgmt_tcp_ports`: ports that are open on the mgmt interface
  * for each of these (currently) 3 sets, there is
    * also an `output` (instead of `input`) variant
    * also a `udp` (instead of `tcp`) variant
    * giving a total of (currently) 12 sets

**warning**: This is work in heavy progress, the `forward` stuff is not yet engineered.

## Variable

(naming to be changed)

`nft_local_traffic` is a list of dicts. Every dict has a name and a list of ports. The name is used to construct the name of the set where the ports go to. So

```
nft_local_traffic:
  - name: output_tcp
    ports:
      - "53"
      - "25"
      - "22, 2222"
      - "80, 443"
  - name: output_udp
    ports:
      - "53"
      - "123"
  - name: input_tcp
    ports:
      - "22"
```

creates the nft file `/etc/nftables.conf.d/basicoutput.nft` which is included by `/etc/nftables.conf`:

```
## Set output_tcp_ports
add element inet filter output_tcp_ports { 53 }
add element inet filter output_tcp_ports { 25 }
add element inet filter output_tcp_ports { 22, 2222 }
add element inet filter output_tcp_ports { 80, 443 }

## Set output_udp_ports
add element inet filter output_udp_ports { 53 }
add element inet filter output_udp_ports { 123 }

## Set input_tcp_ports
add element inet filter input_tcp_ports { 22 }
```

Which can be seen with `nft list ruleset`:

```
        set output_tcp_ports {
                type inet_service
                flags interval
                elements = { 22, 25, 53, 80, 443,
                             2222 }
        }

```

```
        set output_udp_ports {
                type inet_service
                flags interval
                elements = { 53, 123 }
        }

```

```
        set input_tcp_ports {
                type inet_service
                flags interval
                elements = { 22 }
        }

```

and these sets are used here:

```
add rule  inet filter output tcp dport @output_tcp_ports ct state new counter accept comment "output tcp"
add rule  inet filter output udp dport @output_udp_ports ct state new counter accept comment "output udp"
...
add rule  inet filter input  tcp dport @input_tcp_ports  ct state new counter accept comment "input tcp"
```


## Implementation notes

* Naming is still work in progress
* `forward` is not engineered yet
* Format of `/etc/nftables.conf`
  * It took me hours to figure out that the first format for `nft -t` files, the *format seen in the output of nft list*, is not extendable at all.
  * The solution now has the advantage that any role that is executed after the `nft` role can add files in `/etc/nftables.conf.d` in the same format and add elements to the individual sets without needing to know what other applications added. It also saves me from using ugly ansible magic to combine elements of various sources into one. `nftables` does the magic for us. The `unifi` role was the first to use this.
* All nft sets have the flag `interval`. This is why port ranges (e.g. `1027-1030`) would also work in a port list. If you don't need this, it might give you a (probably small) performance gain to remove that flag in `/etc/nftables.conf`.
  
