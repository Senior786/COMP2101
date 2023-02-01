#!/bin/bash

echo "FQDN: $(hostname -f)"
echo "Host Information: "

#echo "Static hostname: "
hostnamectl | grep Static
#echo "Icon name: "
hostnamectl | grep Icon
#echo "Chassis: "
hostnamectl | grep Chassis
#echo "Machine ID: "
hostnamectl | grep Machine
#echo "Boot ID: "
hostnamectl | grep Boot
#echo "Operating System: "
hostnamectl | grep Operating
#echo "Kernel: "
hostnamectl | grep Kernel
#echo "Architecture: "
hostnamectl | grep Architecture

echo "IP Addresses: "
hostname -I
#hostname -i
#ifconfig ens33 |awk '/inet addr:/ {print $2}'|tr -d 'addr:'

echo "Root Filesystem Status: "
df -h /
