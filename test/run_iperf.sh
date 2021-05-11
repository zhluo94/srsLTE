#!/bin/bash

#sudo iptables -o wlp59s0 -A OUTPUT -d 54.67.120.250 -j DROP
#ip route add default dev tun_srsue table srsue
#sudo iptables -o tun_srsue -A OUTPUT -d 172.17.0.0/16 -j DROP
#sleep 5
# ip route add 54.67.120.250 dev tun_srsue table main
#ue_ip=$(ifconfig tun_srsue | grep "inet " | awk '{print $2}')
iperf -c ec2-54-67-120-250.us-west-1.compute.amazonaws.com -i 1 -t 40 #-b 1M
