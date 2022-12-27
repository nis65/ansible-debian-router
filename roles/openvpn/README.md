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

* `openvpn_server_ip`: e.g. 10.8.0.0
* `openvpn_server_mask`: e.g. 255.255.255.0
* `openvpn_server_name`: Currently used for systemd service name only
* Four pointers to crypto files on the **ansible host** (these files must be present to run ansible, but the content is only used when the file is not present on the target yet).
    * `openvpn_dhfile_source`, e.g. `~/vpnsecrets/dh.pem`
    * `openvpn_cafile_source`: e.g. `~/vpnsecrets/ca.crt`
    * `openvpn_certfile_source`: e.g. `~/vpnsecrets/issued/server.crt`
    * `openvpn_keyfile_source`: e.g. `~/vpnsecrets/private/server.key`
* Provided in `defaults`, can be overriden in `host_vars`
    * `openvpn_port`: 1194
    * `openvpn_proto`: udp
    * `openvpn_verb`: 4
    * `openvpn_script_security`: 2
    * `openvpn_client_config_dir`: clientconfig
* **TODO**: nftables integration
    * Base VPN port: only downstream, I guess?
    * nft maps to make individual rules for individual hosts?

## Implementation notes

There are much bigger ansible roles supporting openvpn out there.
* [Rob's role](https://github.com/robertdebock/ansible-role-openvpn) is nice, but does not give me the control of the network settings I need.
* [This role](https://github.com/kyl191/ansible-role-openvpn) seems quite complete, but I was unsure how far I manage to migrate my old setup to this setup. Maybe I should have a look again...
