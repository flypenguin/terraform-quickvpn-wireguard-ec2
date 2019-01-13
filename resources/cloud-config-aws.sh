#!/usr/bin/env bash


# configured by cloud-config
export WG_PKEY="${WG_PKEY}"
export NET_ADDR="${NET_ADDR}"
export NET_MASK="${NET_MASK}"
export NET_PORT="${NET_PORT}"
export PEER_ALLOWED_IPS="${PEER_ALLOWED_IPS}"
export PEER_KEY="${PEER_KEY}"


# get some system info
NET_IFACE=$(ls /sys/class/net/ | grep -Ev '^(wg[0-9]+|lo)$')


# wireguard installation
apt-get install -y software-properties-common
add-apt-repository -y ppa:wireguard/wireguard

apt-get update

apt-get install -y wireguard-dkms wireguard-tools


# wireguard configuration
cd /etc/wireguard

cat > wg0.conf <<EOF
[Interface]
PrivateKey = $WG_PKEY
Address = $NET_ADDR/$NET_MASK
ListenPort = $NET_PORT
SaveConfig = false

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $NET_IFACE -j MASQUERADE
#; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o $NET_IFACE -j MASQUERADE

PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $NET_IFACE -j MASQUERADE
# ; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o $NET_IFACE -j MASQUERADE

[Peer]
PublicKey = $PEER_KEY
AllowedIPs = $PEER_ALLOWED_IPS/24

EOF


# start wireguard service
sysctl -w net.ipv4.ip_forward=1
echo net.ipv4.ip_forward=1 > /etc/sysctl.conf
wg-quick up wg0
systemctl enable wg-quick@wg0