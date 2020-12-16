#!/usr/bin/env bash

# set -x

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script"
    exit 1
fi

if [ "$#" -ne 1 ]; then 
   echo "Illegal number of parameters"
   exit 1
fi

NS="$1"
VETH="veth1"
VPEER="vpeer1"
VETH_ADDR="10.200.1.1"
VPEER_ADDR="10.200.1.2"
LAN_SUBNET="192.168.1.0"
IFACE="wlp59s0"

#trap cleanup EXIT

#cleanup()
#{
#   ip li delete ${VETH} 2>/dev/null
#   ip netns delete $NS
#   rm -rf "/etc/netns/$NS" # removing the directory (including the resolv.conf)
#}

# Remove namespace if it exists.
ip netns del $NS &>/dev/null

# Create namespace
ip netns add $NS

# Setup dns
mkdir -p /etc/netns/"$NS"
ln -s /run/systemd/resolve/resolv.conf /etc/netns/"$NS"/resolv.conf

# Create veth link.
ip link add ${VETH} type veth peer name ${VPEER}

# Add peer-1 to NS.
ip link set ${VPEER} netns $NS

# Setup IP address of ${VETH}.
ip addr add ${VETH_ADDR}/24 dev ${VETH}
ip link set ${VETH} up

# Setup IP ${VPEER}.
ip netns exec $NS ip addr add ${VPEER_ADDR}/24 dev ${VPEER}
ip netns exec $NS ip link set ${VPEER} up
ip netns exec $NS ip link set lo up
ip netns exec $NS ip route add ${LAN_SUBNET}/24 via ${VETH_ADDR} dev ${VPEER}

# Enable IP-forwarding.
echo 1 > /proc/sys/net/ipv4/ip_forward

# Flush forward rules.
# iptables -P FORWARD DROP
# iptables -F FORWARD
 
# Flush nat rules.
# iptables -t nat -F

# Enable masquerading of 10.200.1.0.
iptables -t nat -A POSTROUTING -s ${VPEER_ADDR}/24 -o ${IFACE} -j MASQUERADE
 
iptables -A FORWARD -i ${IFACE} -o ${VETH} -j ACCEPT
iptables -A FORWARD -o ${IFACE} -i ${VETH} -j ACCEPT

# Get into namespace
#ip netns exec ${NS} /bin/bash --rcfile <(echo "PS1=\"${NS}> \"")
