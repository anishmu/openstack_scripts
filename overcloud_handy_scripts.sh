*****************************************
To Delete ALL the Baremetal/Ironic nodes:
*****************************************
#V1
for i in `openstack baremetal node list | awk '{print $2}' | awk 'NR>3'`;do openstack baremetal node delete $i; done

#V2
for node in $(openstack baremetal node list --fields uuid -f value) ; do openstack baremetal node delete $node ; done

*******************************
Ipmitool Power of all servers:
*******************************
for i in 109 110 111 112 113 114 115 116 117
  do ipmitool -H 10.118.147.$i -v -I lanplus -U root -P calvin chassis power off;
done

************************************************************
Check the failed deployments analysing heat stack resources:
************************************************************
# V1:Deprecated:
source stackrc
for failed_deployment in $(heat resource-list --nested-depth 5 overcloud | grep FAILED | grep -E 'OS::Heat::SoftwareDeployment |OS::Heat::StructuredDeployment ' | cut -d '|' -f 3); do
        echo $failed_deployment;
        heat deployment-show $failed_deployment;
done

# V2:Latest with OpenStack client
source stackrc
for failed_deployment in $(openstack stack resource list --nested-depth 5 overcloud | grep FAILED | grep -E 'OS::Heat::SoftwareDeployment |OS::Heat::StructuredDeployment ' | cut -d '|' -f 3); do
        echo $failed_deployment;
        openstack software deployment show $failed_deployment;
done

# V3: Heat stack/resource analysis step by step, to debug Overcloud Stack
openstack stack list --nested | grep FAILED
It will lists lots of nested stacks and main stack is listed at last(that is our overcloud stack)

openstack stack resource list bf2ce49d-f678-47ae-9edb-aa744a2b46a1
It will lists resource and their status. Look for the one which is in failed state
The valuable information for us here, is the physical_resource_id.This helps in finding out why our deployment failed.

openstack software deployment show PHYSICAL-RESOURCE-ID --long
Look for status reason field here which will give you clue.

***********************************************************
Set all baremetal nodes to manageable state in Provisiong:
***********************************************************
for node in $(openstack baremetal node list --fields uuid -f value) ; do openstack baremetal node manage $node ; done

