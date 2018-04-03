#!/bin/bash

# This bash script clears the entire network topology
# AUTHOR: PRAVEEN N

# This script assumes your public/external network name as "public"

# Dissocaite the floating IPs
for i in ` openstack floating ip list | awk '{print $2}' | awk 'NR>3' `
do
        openstack floating ip delete $i
done

# Clear router interfaces for all subnets, then
# delete router. Repeat for all routers.
for i in ` openstack server list | awk '{print $2}' | awk 'NR>3'`; do nova delete $i; done
sleep 15s

# NR>3 is to skip first 3 lines in the output

for i in `openstack router list | awk '{print $2}' | awk 'NR>3' `
do
    for j in ` openstack subnet list | awk '{print $2}' | awk 'NR>3' `
    do
         neutron router-interface-delete $i $j
         sleep 4s
    done
    neutron router-gateway-clear $i public
    openstack router delete $i
done

# Delete all the networks
for m in ` openstack network list | awk '{print $2}' | awk 'NR>3'`; do neutron net-delete $m; done
