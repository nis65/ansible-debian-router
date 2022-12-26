
# routing

This role enables routing on the target system.

## Variables

## Implementation notes

* We are **not** using `systemd.network`, so this is the classic sysctl implementation.
* I decided against using the `ansible.posix.sysctl` module, as this would be the first external dependency and it is easy to do without.


