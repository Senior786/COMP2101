#!/bin/bash

echo
fqdn=$(hostname -f) #create variable and saves output for FQDN
osnw=`hostnamectl | grep Operating | cut -f2 -d":"` #create variable and saves output for os name and its version
hst=$(hostname -I) #create variable and saves output for knowing IP address
rd=`df -h / | tail -1 | awk '{print $4}'` #create variable and saves output for root filesystem 


# this will prints the created output in formated method.
cat <<EOF
Report for myvm
===============
FQDN: $fqdn
Operating System name and version: $osnw
IP Addresses: $hst
Root Filesystem Free space: $rd
===============
EOF
echo

