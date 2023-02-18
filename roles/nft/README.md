
# nft

This role directly configures `nftables` via configuration files. In order to make the nftable
configuration easily extendable (other roles can add or remove files in a certain directory
without having to edit a file), I am using the *syntax of calling the nft binary several times, but in an atomic fashion*,
see [here](https://wiki.nftables.org/wiki-nftables/index.php/Scripting#File_formats).

## Variables

* `host_vars`:
    * `nft_upstream_interface`: Interface name of upstream interface (towards the internet), e.g. `enp1s0`
    * `nft_mgmt_interface`: Introduced to support the `unifi` role: unifi hardware is connected to this subnet only.
    * `nft_downstream_interfaces`: A list of all interfaces you consider as *downstream*, this is useful for local services like dns and dhcp. In my setting, it is equivalent to *all interfaces except upstream and vpn*.
* `defaults`:
   * `nft_base_dports` is a list of dicts. Every dict has a name and a list of ports. The name is used to construct the name of the set where the ports go to (see e.g. `input_tcp_dports` above).

```
nft_base_dports
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

## nftables design

The base configuration goes to `/etc/nftables.conf` and configures the following
* A `filter` table with three chains: `input`, `output`, `forward`. This is functionally equivalent to the old `iptables` concept.
* Each chain has policy `drop`, so if you don't explicitly allow traffic, it will be blocked
* Each rule has a counter associated to check if the rules get actually used
* Each chain has some default `accept` filters:
    * localhost (on input/output) is always allowed
    * ICMP/ICMPv6 is always allowed (you might want to be more strict on that)
    * **TODO** document/test igmp
    * return packets are always allowed (i.e. they can be associated with an earlier packet, stateful!)
    * DHCP requests from the upstream interface (and its replies) are always allowed (stateless)
* The `input` and `output` chains jump to an application rule sub chain that is empty when only the `nft` role is executed
* The last rule of these chains is a `log` rule, so all blocked packets are logged
* A `masq` table with one `postrouting` rule to masquerade all traffic from the downstream interfaces to the upstream interface (stateful).

The configuration includes all files with a filename matching `/etc/nftables.conf.d/*.nft`. These files
can contain any `nft` command. Later roles should place their application specific firewall rules
there, the `nftbase.nft.j2` template in this role is an example for such a file.

There are two kinds of predefined objects in the base configuration that make it simpler for the
following roles to extend the firewall:

* one or more ports can be added to a [set](https://wiki.nftables.org/wiki-nftables/index.php/Sets) of destination ports (`inet_service` in nft terms). The name of the set defines what kind of traffic will be allowed:
    * `input` or `output` (received packet or sent packet)
    * `tcp` or `udp`
    * *no explicit interface* or `downstream` or `mgmt`: A rule affects either all interfaces or all `downstream` interfaces or all `mgmt` interfaces
    * examples:
        * `output_tcp_dports` is the list of destination tcp ports allowed to initiate a new connection over all interfaces.
        * `input_downstream_udp_dports` is the list of destination udp ports allowed to initiate a new connection over the downstream interfaces.
* you can add arbitrary `nft` rules to the sub chains `input_apprules` and `output_apprules` (the dnsmasq role uses this), e.g.
  * `add rule inet filter input_apprules ...`
  * `add rule inet filter output_apprules ...`

## Other implementation notes

* The default debian `nftables.service` is extended to propagate restarts and reloads to `fail2ban`. See issue [#43](https://github.com/nis65/ansible-debian-router/issues/43) for more details.
* You might want to install the `conntrack` package to easily view the currently tracked connections.
* Format of `/etc/nftables.conf`
  * It took me hours to figure out that the first format for `nft -t` files, the *format seen in the output of nft list*, is not extendable at all.
  * The solution now has the advantage that any role that is executed after the `nft` role can add files in `/etc/nftables.conf.d` in the same format and add elements to the individual sets without needing to know what other applications added. It also saves me from using ugly ansible magic to combine elements of various sources into one. `nftables` does the magic for us. The `unifi` role was the first to use this.
* All nft sets have the flag `interval`. This is why port ranges (e.g. `1027-1030`) would also work in a port list. If you don't need this, it might give you a (probably small) performance gain to remove that flag in `/etc/nftables.conf`.
  
