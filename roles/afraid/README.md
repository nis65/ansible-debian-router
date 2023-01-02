
# afraid

Home users usually don't get a static IP from their provider. In order to make the
`openvpn` Server available from the internet easily, we need a stable domain name (FQDN)
for our router. 

I am using [afraid.org](https://freedns.afraid.org/) to publish the IP-Adress of my 
home router in the worldwide DNS. There are a lot of alternatives to that service.

This role installs a small shell script and systemd units to regularly check whether the
upstream interface ip address still matches the DNS record. 
If not, an update request is done.

**NOTE**: You need to configure your individual update URL in `/etc/default/afraid` before
updates are actually done.

## Variables

There are only very use case specific variables to set, so everything should go to `host_vars`:

* `afraid_external_vpn_interface`: This is the interface name that has the public routable ip address that should be in dyndns
* `afraid_domain_name`: The DNS name that should point to the address of that interface.

## Implementation notes

The script is currently started every 5 minutes. Your mileage may vary. See the result of the 
latest update in `/tmp/latest_afraid_update.txt`.
