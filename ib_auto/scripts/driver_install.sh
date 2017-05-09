#!/bin/bash
# Program:
#	Only use to install mellanox driver.
# History:
#	Author Lester	2017.3.16

wget ftp://100.2.70.18/NF5270M4/$1/$3 -P tmp
tar -xvf tmp/$3 -C tmp
driver_dir=`echo $3 | awk -F'.tgz' '{print $1}'` 
./tmp/$driver_dir/mlnxofedinstall $4
echo
echo "Now your driver have been installed successfully!"
echo "openibd will restart now!"
/etc/init.d/openibd restart > /dev/null
echo -e "\033[31mRecommened restart your server immediately!"
