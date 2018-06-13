###################################################
#SCRIPT1: To Delete ALL the Baremetal/Ironic nodes:
###################################################
# V1: delete all nodes
for i in `openstack baremetal node list | awk '{print $2}' | awk 'NR>3'`;do openstack baremetal node delete $i; done

# V2: Set ironic nodes to manageable state
for node in $(openstack baremetal node list --fields uuid -f value) ; do openstack baremetal node manage $node ; done

##########################################################
#SCRIPT2: Ipmitool Power off/check status all the servers:
##########################################################
# Last octet of IDRAC IPs sequentially
for i in 117 109 110 111 112 113 114 115 116
  do ipmitool -H 10.118.147.$i -v -I lanplus -U root -P calvin chassis power off;
done

# Check power status
for i in 117 109 110 113 114 115 116; do ipmitool -H 10.118.147.$i -v -I lanplus -U root -P calvin chassis power status; done

##############################################################################################
#SCRIPT3: Check the failed deployments analysing heat stack resources for SOFTWARE DEPLOYMENTS
##############################################################################################
# V1: Using OpenStack client
source stackrc
for failed_deployment in $(openstack stack resource list --nested-depth 5 overcloud | grep FAILED | grep -E 'OS::Heat::SoftwareDeployment |OS::Heat::StructuredDeployment ' | cut -d '|' -f 3); do
        echo $failed_deployment;
        openstack software deployment show $failed_deployment;
done

# V2: Using Deprecated client
source stackrc
for failed_deployment in $(heat resource-list --nested-depth 5 overcloud | grep FAILED | grep -E 'OS::Heat::SoftwareDeployment |OS::Heat::StructuredDeployment ' | cut -d '|' -f 3); do
        echo $failed_deployment;
        heat deployment-show $failed_deployment;
done


#######################################################
#SCRIPT4: to filter out actual configurations in a file
#######################################################
cat undercloud.conf | grep -v ^# | grep -v ^$


####################################
# TAGGING NODES INTO PROFILES
####################################
#sequentially node UUID is considered at 3rd awk with arg NR == <SL. NO>
# control
openstack baremetal node set --property capabilities='profile:control,boot_option:local' `openstack baremetal node list | awk '{print $2}' | awk 'NR >3' | awk 'NR == 1 {print $1}'`
openstack baremetal node set --property capabilities='profile:control,boot_option:local' `openstack baremetal node list | awk '{print $2}' | awk 'NR >3' | awk 'NR == 2 {print $1}'`
openstack baremetal node set --property capabilities='profile:control,boot_option:local' `openstack baremetal node list | awk '{print $2}' | awk 'NR >3' | awk 'NR == 3 {print $1}'`

#compute-sriov
openstack baremetal node set --property capabilities='profile:compute,boot_option:local' `openstack baremetal node list | awk '{print $2}' | awk 'NR >3' | awk 'NR == 4 {print $1}'`
openstack baremetal node set --property capabilities='profile:compute,boot_option:local' `openstack baremetal node list | awk '{print $2}' | awk 'NR >3' | awk 'NR == 5 {print $1}'`

#ceph-storage
openstack baremetal node set --property capabilities='profile:ceph-storage,boot_option:local' `openstack baremetal node list | awk '{print $2}' | awk 'NR >3' | awk 'NR == 6 {print $1}'`
openstack baremetal node set --property capabilities='profile:ceph-storage,boot_option:local' `openstack baremetal node list | awk '{print $2}' | awk 'NR >3' | awk 'NR == 7 {print $1}'`
