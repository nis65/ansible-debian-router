# openvpn

This is a very simple openvpn ansible role, but fully supports my usecase:

* VPN clients are authenticated by certificates only, but there is no support in this role whatsoever for you own CA (which is what is needed for certificate authentication).
* As the main use case for this role is migration from an existing installation, the key/certificate files are expected to exist:
    * if they are present on the target host, nothing is done (existing file is never overwritten, even when it's different).
    * if they are missing, they are copied from the ansible host (see variable settings below). If you want to force a copy, just delete them on the target host before running the playbook.
* Support for **client-config-dir** implemented because I have different kinds of VPN clients:
    * most clients don't want a default route, but for some I want to switch it on (on server side), e.g. for my laptop abroad.
    * some want to access services, e.g. the file share or the music stream. These get my internal DNS-Server pushed.
    * some only need a network connection to enable remote management even when they are behind NAT. In order to minimize the impact of the VPN on the client, they don't get a DNS-Server pushed.
    * if there is file in this directory whose name matches the name in the certificate, this will be executed.
    * there a is *DEFAULT* client config provided (details to follow) as fallback.
* There is no support for multiple openvpn servers on the same host.

**WARNING** work in progress, do not (yet) use!

## Variables

To be set in `host_vars`:

* `openvpn_server_interfaces`: a list of interfaces where connects are accepted. Usually at least the upstream interface, e.g. `enp1s0`.
* `openvpn_server_ip`: subnet where vpn clients get their ip from, e.g. 10.8.0.0
* `openvpn_server_mask`: e.g. 255.255.255.0
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
* `openvpn_push_dns`: the configuration which clients get dns information pushed and what information they get pushed
~~~
openvpn_push_dns:
  clientlist:
    - nicolas-mobile
  dnsserverips:
    - 10.8.0.1
  dnsdomains:
    - mydomain.net
    - myotherdomain.ch
~~~
* `openvpn_nft_targets_smb`: a list of target ip adresses of `smb` servers in your local network you want give access to at least one vpn client
* `openvpn_nft_targets_imaps`: a list of target ip adresses of `imaps` servers in your local network you want give access to at least one vpn client
* `openvpn_nft_client_rules`: a list of dicts defining what vpn clients (defined by the name in the client certificate) have access to what service. The value of the `name` attribute is used to construct the filternames as defined in `templates/etc/nftables.conf.d/openvpn.nft.j2`. **WARNING** The client names **must** be `define`d  in that jinja template (e.g. `define zeta = { 10.8.0.99 }`), otherwise an invalid nftables configuration is generated. **TODO** build a a script that parses the openvpn persistent ip database and produces an includable file that contains all needed defines.
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
~~~

Provided in `defaults`, can be overriden in `host_vars`
* `openvpn_port`: 1194
* `openvpn_proto`: udp
* `openvpn_verb`: 4
* `openvpn_write_ipp_sec`: 60
* `openvpn_script_security`: 2
* `openvpn_client_config_dir`: clientconfig

## Implementation notes

There are much bigger ansible roles supporting openvpn out there.
* [Rob's role](https://github.com/robertdebock/ansible-role-openvpn) is nice, but does not give me the control of the network settings I need.
* [This role](https://github.com/kyl191/ansible-role-openvpn) seems quite complete, but I was unsure how far I manage to migrate my old setup to this setup. Maybe I should have a look again...
