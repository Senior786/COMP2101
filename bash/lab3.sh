#!/bin/bash

#Installing lxd as the system does not have it...
which lxd > /dev/null
# i am using $? command to check previous command
if [ $? -ne 0 ]; then 

        echo "Installing lxd" 
        sudo snap install lxd
        if [ $? -ne 0 ]; then

                echo "lxd installation failed"
                exit 1 # if installtion fails this will be executed.
        fi
else
echo "Lxd is already installed....."
fi

#lxdbr0 bridge interface will be checked..

if [ $? -ne 1 ]; then
        echo "Initializing lxd"
        lxd init --auto > /dev/null
        if [ $? -ne 0 ]; then

                echo "lxd initialization failed. Ending script execution"
                exit 1  # this if will be executed one the bridge is not found.
        fi
else
echo "Network bridge is already present....."
fi

#Creating a container if it is not present.
lxc list | grep -w "COMP2101-S22" > /dev/null
if [ $? -ne 0 ]; then
        echo "Creating container COMP2101-S22 as Ubuntu 20.04 server"
        lxc launch ubuntu:20.04 COMP2101-S22
        if [ $? -ne 0 ]; then
                echo "Container creation unsuccessful"
                exit 1
        fi
else
echo "container is already present...."
fi

#Adding the name COMP2101-S22 with the container’s IP address in /etc/hosts if it is not present already by default.

grep -w "COMP2101-S22" /etc/hosts > /dev/null

if [ $? -ne 0 ]; then
                echo "Appending failed...."
                exit 1
fi


#Retrieving page from web service and notyfying success or failure of creation.

echo "Checking default web page retrival from container COMP2101-S22"
curl http://COMP2101-S22 > /dev/null

if [ $? -ne 0 ]; then
        echo "Default web page retrieval was unsuccessful"
else
        echo "Default web page retrieval was successful"
fi
