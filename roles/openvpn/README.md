# openvpn

This openvpn ansible role just covers my use case.

* VPN clients are authenticated by certificates only, but there is **no support** in this role whatsoever to maintain a CA. But all client specific features rely on your ability to generate, manage and distribute certificates to the VPN clients.
* As the main use case is migration from an existing installation, the key/certificate files are simply expected to exist / to be managed somewhere on the ansible host:
    * if they are present on the target host, nothing is done (existing file is never overwritten, even when it's different).
    * if they are missing, they are copied from the ansible host (see variable settings below). If you want to force a copy, just delete them on the target host before running the playbook.
* Support for **client-config-dir** implemented
    * different levels of access by VPN clients:
        * least privileged/always on: the client connects to the vpn automatically and is accessible via `ssh`. This enables me to do remote management even if it is behind NAT. No DNS Server pushed.
        * normal privileges: access to some local services (and other vpn clients).
        * full privileges: access to some local services and masquerading IPv4 / routing IPv6 to the internet.
    * if there is file in this directory whose name matches the name in the certificate, this will be executed by `openvpn`
    * there a is *DEFAULT* client config provided (currently empty). You can add options there to get pushed to all clients except the ones that have an individual client config.
* There is no support for multiple openvpn servers on the same host in this role.

## Variables

To be set in `host_vars`:

* `openvpn_server_interfaces`: a list of interfaces where connects are accepted. Usually at least the upstream interface, e.g. `enp1s0`.
* `openvpn_internet_interface`: one interface name, used as target interface when allowing incoming vpn traffic to access the internet (see below). Usually the upstream interface, e.g. `enp1s0`.
* `openvpn_tls_version_min`: Do not set this unless you really need it. I have one old client that makes me set it to '1.0' (see openvpn manual).
* `openvpn_server_ip`: subnet where vpn clients get their ip from, e.g. `10.8.0.0`
* `openvpn_server_mask`: e.g. `255.255.255.0`
* `openvpn_server_ipv6`: e.g. `2001:db8:1234:6f3::1/64`
* `openvpn_server_name`: Currently used for systemd service name only
* Four pointers to crypto files on the **ansible host** (these files must be present to run ansible, but the content is only used when the file is not present on the target yet).
    * `openvpn_dhfile_source`, e.g. `~/vpnsecrets/dh.pem`
    * `openvpn_cafile_source`: e.g. `~/vpnsecrets/ca.crt`
    * `openvpn_certfile_source`: e.g. `~/vpnsecrets/issued/server.crt`
    * `openvpn_keyfile_source`: e.g. `~/vpnsecrets/private/server.key`
* `openvpn_pushroutes`: a list of dicts. If you want to have any communication between the vpn clients and your local networks (independent of the direction of the communication initiation), you will have to push the subnets of your local networks to the openvpn clients.
~~~
openvpn_pushroutes:
  - address: 172.30.0.0
    mask: 255.255.254.0
  - address: 172.27.0.1
    mask: 255.255.255.0
~~~
* `openvpn_pushroutes_ipv6`: similar to the IPv4 version above, except that only prefixed `address:` (and no `mask`) is needed, e.g. `2001:db8:1234:6f0::/60`
* `openvpn_client_options`: client specific configuration. `options` are added line by line to the client config file, if `dnsoptions` is set to `yes`, the DNS server information is pushed (see next variable). `name` matches the name in the client certificate and is mandatory, the other two are optional:
~~~
openvpn_client_options:
  - name: zeta
    options:
      - 'push "comp-lzo yes"'
      - 'comp-lzo yes'
    dnsoption: yes
  - name: alpha
    dnsoption: yes
  - name: zeta
    options:
      - 'push "comp-lzo yes"'
      - 'comp-lzo yes'
~~~
* `openvpn_client_push_dns:`: the details for the DNS configuration to be pushed (if at all, see previous variable).
~~~
openvpn_client_push_dns:
  dnsserverips:
    - 10.8.0.1
  dnsdomains:
    - mydomain.net
    - myotherdomain.ch
~~~
* `openvpn_dns_domain`: the domain name that should be appended to the hostname as defined in the client certificate. This is used to add the vpn client names to the dnsmasq host list.
* `openvpn_nft_targets_smb`: a dict of two lists, one for IPv4, the other for IPv6 addresses. These ar tarrget ip adresses of `smb` servers in your local network you want give access to at least one vpn client
~~~
openvpn_nft_targets_smb:
  v4info:
    - 172.30.0.126
  v6info:
    - 2001:db8:1234:6f0::1234
~~~

* `openvpn_nft_targets_imaps`: similar to `openvpn_nft_targets_smb`, but affects the imaps port.
* `openvpn_nft_targets_ucshttps`: similar to `openvpn_nft_targets_smb`, but affects the https port.
* `openvpn_nft_client_rules`: a list of dicts defining what vpn clients (defined by the name in the client certificate) have access to what service. The value of the `name` attribute is used to construct the filternames as defined in `templates/etc/nftables.conf.d/openvpn.nft.j2`. 
   * **WARNING** The client names referred to in those configs can only be used when they are already present in `/var/log/openvpn/ipp.txt` on the target system. So you always have to connect first via VPN with a new client before you can use its name in these config variables. The `systemd` unit `openvpnmapping` ensures that new connections are immediately mirrored to both `/etc/nftables.conf.d/clients.openvpn` and `/etc/dnsmasq.hosts.d/hosts.openvpn` so that the required mapping from a name to both its IPv4 and IPv6 addresses is known to both nftables and dnsmasq.
   * `vpn_unifi` allows to access a unifi instance on a remote vpn client from another vpn client
   * `internet` allows to access the internet (IPv4: masquerading/IPv6: routing) from a vpn client. Note that these rules are only configured when `openvpn_internet_interface` is defined.
~~~
openvpn_nft_client_rules:
  - name: localhost_dns
    clients:
      - lambda
  - name: localhost_ssh
    clients:
      - lambda
  - name: localhost_unifi
    clients:
      - lambda
      - zeta
  - name: localnet_ssh
    clients:
      - lambda
  - name: localnet_smb
    clients:
      - lambda
  - name: localnet_music
    clients:
      - lambda
  - name: localnet_imaps
    clients:
      - lambda
  - name: localnet_ucshttps
    clients:
      - lambda
  - name: vpn_unifi
    clients:
      - lambda
  - name internet
    clients:
      - lambda
~~~

Provided in `defaults`, can be overriden in `host_vars`
* `openvpn_port`: 1194
* `openvpn_proto`: udp
* `openvpn_verb`: 4
* `openvpn_write_ipp_sec`: 60
* `openvpn_script_security`: 2

## Implementation notes

There are much bigger ansible roles supporting openvpn out there.
* [Rob's role](https://github.com/robertdebock/ansible-role-openvpn) is nice, but does not give me the control of the network settings I need.
* [This role](https://github.com/kyl191/ansible-role-openvpn) seems quite complete, but I was unsure how far I manage to migrate my old setup to this setup. Maybe I should have a look again...
