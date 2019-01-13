# Quick VPN Wireguard

## TL;DR

Creates a ready-to-use Wireguard VPN server on EC2.

## Longer description

This is a terraform module which creates a ready-to-connect [Wireguard](https://www.wireguard.com) VPN server for you.

It solves the same problem as [Algo](https://github.com/trailofbits/algo/), but I thought with a little bit less overhead. If you want features, flexibility, well-tested things, anything remotely *good*, then head over to them. This is something very useful I put together on a sunday, but it's not comparable. I wrote this because I was *absolutely, massively fed up* from those VPN providers, and I have a Windows PC now. Algo, as good as it is, is a bit too much "linux'ey" for a one-step-solution.

If you're still reading, good :) .

This is the minimum example:

```terraform
module "vpnserver" {
    source                = "tbd"
    wg_server_public_key  = "..."
    wg_server_private_key = "..."
    wg_client_public_key  = "..."
    wg_client_private_key = "..."
    region                = "any-valid-aws-region"
}
```

After being done, you can get the client configuration using

```bash
terraform output client_config
```

... and use, for example, [TunSafe](https://tunsafe.com/) to connect from Windows. Yes, Windows.

## How to use

- Create the two key pairs (on Windows you can use TunSafe for this, it has a key generator built in)
- Run the terraform module
- Done.

## Future plans

- Create a lightsail version from this, cheaper for longer running servers