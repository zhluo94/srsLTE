#!/bin/bash

sleep 3
ip route add default dev tun_srsue
iperf -c ec2-54-67-120-250.us-west-1.compute.amazonaws.com -i 1 -t 10 -b 10M
