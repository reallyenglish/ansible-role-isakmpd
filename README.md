# ansible-role-isakmpd

Configure OpenBSD isakmpd.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| isakmpd\_user | user name of the daemon | {{ \_\_isakmpd\_user }} |
| isakmpd\_group | group name of the daemon | {{ \_\_isakmpd\_group }} |
| isakmpd\_service | service name | isakmpd |
| isakmpd\_conf | path to `ipsec.conf`. | {{ \_\_isakmpd\_conf }} |
| isakmpd\_flags | flags for the daemon | -K |
| isakmpd\_conf\_dir | directory of file that the role creates as an anchor (beta) | /etc/pf.conf.d |
| isakmpd\_listen\_address | address for the daemon to bind to | "" |
| isakmpd\_addresses | a dict of address lists that is used in isakmpd\_flows | "" |
| isakmpd\_flows | the flows | {} |
| isakmpd\_default\_flow | defaults for site and l2tp types of isakmpd\_flows | {"site"=>{"main"=>{"auth\_algorithm"=>"hmac-sha1", "enc\_algorithm"=>"aes-128", "group"=>"modp1024", "lifetime"=>nil}, "quick"=>{"auth\_algorithm"=>"hmac-sha1", "enc\_algorithm"=>"aes-128", "lifetime"=>nil}}, "l2tp"=>{"main"=>{"auth\_algorithm"=>"hmac-sha1", "enc\_algorithm"=>"aes-128", "group"=>"modp1024", "lifetime"=>nil}, "quick"=>{"auth\_algorithm"=>"hmac-sha1", "enc\_algorithm"=>"aes-128", "lifetime"=>nil}}} |

## OpenBSD

| Variable | Default |
|----------|---------|
| \_\_isakmpd\_user  | \_isakmpd |
| \_\_isakmpd\_group | \_isakmpd |
| \_\_isakmpd\_conf  | /etc/ipsec.conf |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-isakmpd
  vars:
    isakmpd_listen_address: 192.168.68.1
    isakmpd_addresses:
      peer1: 192.168.68.1
      peer2: 192.168.68.2

    isakmpd_flows:
      peer2:
        type: site
        psk: password
        main:
          lifetime: 10m
        quick:
          lifetime: 3600
      client:
        type: l2tp
        main:
          auth_algorithm: hmac-sha1
          enc_algorithm: 3des
          group: modp1024
          lifetime: 1200
        quick:
          auth_algorithm: hmac-sha2-256
          enc_algorithm: aes
        psk: password
```

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [ansible-role-init](https://gist.github.com/trombik/d01e280f02c78618429e334d8e4995c0)
