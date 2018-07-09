#!/bin/sh

# Usage: ./disable_port_sec.sh IP1 IP2 ....
# source overcloudrc before running script

for ip in "$@"
do
        #neutron port-show `neutron port-list | grep "$ip" | awk '{print $2}'` | grep security
        neutron port-update `neutron port-list | grep "$ip" | awk '{print $2}'` --no-security-groups
        neutron port-update `neutron port-list | grep "$ip" | awk '{print $2}'` --port-security-enabled=False
done
