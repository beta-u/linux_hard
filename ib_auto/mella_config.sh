#!/bin/bash
# Program:
# 	This scripts only use to config mellanox Infiniband or Ethernet card.
# History:
#	v1.0 beta (no update yet)

echo -e "\033[41m  ################################  \033[0m"
echo -e "\033[41m  #####  wrote by lester #########  \033[0m"
echo -e "\033[41m  ######### 2017.3.6  ############  \033[0m"
echo -e "\033[41m  ######## hca config lead #######  \033[0m"
echo -e "\033[41m  ################################  \033[0m"
echo 

function env_prepare(){
	mpirun_lo=`find /usr/mpi/gcc -name mpirun | grep openmpi |sort -r | awk NR==1`
	mpirun_dir=`dirname $mpirun_lo`
	mpi_dir=`dirname $mpirun_dir`
	mpirun_check=`cat /root/.bashrc | grep mpirun`
	if [ "$mpirun_check" == "" ];then
		echo "export PATH=$mpirun_dir:$PATH" >> /root/.bashrc
		source /root/.bashrc
	fi
#	echo -e "\033[41m >>  Environment Check  <<  \033[0m"
	echo -e "\033[31mALL failed items will be fixed after check!\033[0m"
	echo

	python -m docopt
	if [ $? -ne 0 ];then
		echo -e "\033[41m1.docopt checking  ------------------ Failed\033[0m"
		doc_check=false
	else
		echo -e "\033[33m1.docopt checking  ------------------ Passed\033[0m"
		doc_check=true
	fi

	chmod +x -R scripts
	if [ $? -eq 0 ];then
		echo -e "\033[33m2.Permission granting ---------------- passed\033[0m"
		ex_check=true
	else
		echo -e "\033[31m2.Permission granting ---------------- Failed\033[0m"
		echo -e "\033[31m  Permission denied, some function may not work\033[0m."
		ex_check=false
	fi
	echo -e "\033[33m3.Cleaning tmp file ---------------- Passed\033[0m"
#	read -p "This will delete all tmp file, enter 'discard' to cancel, any other key to continue: " tmp_check
#	if [ "$tmp_check" != "discard" ];then
		rm -rf tmp/*
#	else
#		continue
#	fi

	which expect > /dev/null 2>&1
	if [ $? -ne 0 ];then
		echo -e "\033[31m4.Expect checking ------------------ Failed\033[0m"
		expect_check=false
	else
		echo -e "\033[33m4.Expect checking ------------------ Passed\033[0m"
	fi
	
	which pssh > /dev/null 2>&1
	if [ $? -ne 0 ];then
		echo -e "\033[31m5.Pssh checking ----------------- Failed\033[0m"
		pssh_check=false
	else
		echo -e "\033[33m5.Pssh checking ----------------- Passed\033[0m"i
		pssh_check=true
	fi
	

	if ! $doc_check;then
		tar -xvf packages/docopt* -C tmp/
		cd tmp/docopt*
		python setup.py install
		cd ../..
		echo -e "\033[33mdocopt ok!\033[31m"
	fi

	if ! $expect_check;then
		rpm -ivh packages/expect*
		echo -e "\033[33mexpect ok!"
	fi
#	echo -e "\033[41m >>  Environment Check Finished  <<  \033[0m"
	echo

	if ! $pssh_check;then
		tar -xvf packages/pssh-2.3.1.tar.gz -C tmp/
		cd tmp/pssh*
		python setup.py install
		cd ../../
		echo -e "\033[33mpssh ok!\033[31m"
	fi
}

function driver_select(){

	read -p "Please enter your system type (rhel centos suse ubuntu): " system
	read -p "Please enter your system release (ex. 6.6 7.2 12.2...): " release
	os="$system$release"
	echo -e "\033[33mYour system is $os.\033[0m"
	display=`python ./scripts/hca_driver.py $system $release`
	echo $display
	test=`echo $display | grep exist`
	if [ "$test" = "" ];then
		echo "The latest driver of $os is $display ."
		nu_me=`lspci | grep -i mellanox | wc -l`
		nu_ib=`ip addr show | grep infiniband | wc -l`
		if [ "$nu_me" = "$nu_ib" ];then
			echo -e "Mellanox driver already exist! Next step will upgrade it!"
			read -p "Enter 'discard' to cancel the upgrade, any other key to continue: " discard
			if [ "$discard" = "discard" ];then
				echo "You choose to cancel the upgrade!"
				continue
			else
				./scripts/driver_install.sh $system $release $display --update
			fi
		else
			echo "Can't detect mellanox driver, next step will execute fresh install!"
			read -p "Press any key to continue."
			./scripts/driver_install.sh $system $release $display --update
		fi
	else
		echo "$display"
		echo
		continue
	fi
}

#function network_config(){
#	read -p "Enter your system type(rhel centos suse ubuntu): " system
#	case $system in
#	"rhel"|"centos")
#		net_config_dir="/etc/sysconfig/network-scripts"
#		;;
#	"suse")
#		net_config_dir="/etc/sysconfig/network"
#		;;
#	"ubuntu")
#		net_config_dir="/etc/network/interface"
#		;;
#	*)
#		echo "The $system not supported!"
#		continue
#		;;
#	esac
#	
#	net_config_dir="/etc/sysconfig/network_config"
#	read -p "Do you want to clear the IB network you have now?(y/n) " check_1
#	if [ "$check_1" = "n" ];then
#		echo "You canceled the network reconfig!"
#		continue
#	else
#		nu_ib=`ip addr show | grep infiniband | wc -l`
#		echo "There are $nu_ib IB port"
#		rm -rf $net_config_dir/ifcfg-ib*
#		read -p "How many port you want to config: " nu_config
#		if [ "$nu_config" -gt "$nu_ib" ];then
#			echo -e "\033[31mThere are no such many IB port.\nQUIT now\033[0m"
#			continue
#		fi
#		read -p "Enter the static ip address: " ip_address
#		ip_end=`echo $ip_address | awk -F'.' '{print $NF}'`
#		echo $ip_end
#		ip_head=`echo $ip_address | cut -d'.' -f1,2,3`
#		echo $ip_head
#		read -p "Enter the netmask: " netmask
#		echo $((nu_config-1))
#		for i in $(seq 0 $((nu_config-1)))
#		do
#			ip_address=`python ./scripts/ip_create.py $ip_head $ip_end`
#			echo "DEVICE=ib$i">> $net_config_dir/ifcfg-ib$i
#			echo "NAME=ib$i">> $net_config_dir/ifcfg-ib$i
#			echo "BOOTPROTO=static" >> $net_config_dir/ifcfg-ib$i
#			echo "IPADDR=$ip_address" >> $net_config_dir/ifcfg-ib$i 
#			echo "NETMASK=$netmask" >> $net_config_dir/ifcfg-ib$i
#			echo "ONBOOT=yes" >> $net_config_dir/ifcfg-ib$i
#			ip_end=$((ip_end+1))
#		done
#		ip addr show | grep mtu | grep ib | grep -v LOOPBACK | cut -d' ' -f2| cut -d: -f1 >> tmp/nic_list
#		cat tmp/nic_list
#		for nic in `cat tmp/nic_list`
#		do
#			mac=`ip addr show $nic | grep infiniband | awk '{print $2}'`
#			echo "HWADDR=$mac" >> $net_config_dir/ifcfg-${nic}
#		done
#		echo "Network config complished!"
#		echo "Shutting down NetworkManager ..."
#		systemctl stop NetworkManager
#		echo "Disabling NetworkManager ..."
#		systemctl disable NetworkManager
#		echo "IB link restarting ..."
#		for nic in `cat tmp/nic_list`
#		do
#			ifconfig $nic down
#			ifconfig $nic up
#		done
#		
#	fi
#}

function hostset(){
	read -p "system release(6/7): " sr
	if [ "$sr" == "6" ];then
		sed -i 's/HOST/#HOST/g' /etc/sysconfig/network
		echo "HOSTNAME=$1" >> /etc/sysconfig/network	
	else
		hostnamectl set-hostname $1
	fi
}


function network_config(){
	systemctl stop NetworkManager 
	systemctl disable NetworkManager
	read -p "Enter the hostname(m1/m2): " check_hostname
	case $check_hostname in 
	"m1")
		hostset $check_hostname
		echo "HOSTNAME set!"
		echo "Your ib nic will be configured at 192.168.1.0/24"
		echo "Your previous config will be overwrite!"
		cp ./config/$check_hostname/ifcfg-ib0 /etc/sysconfig/network-scripts/ 
		;;
	"m2")
		hostset $check_hostname
		echo "HOSTNAME set!"
		echo "Your ib nic will be configured at 192.168.1.0/24"
		echo "Your previous config will be overwrite!"
		cp ./config/$check_hostname/ifcfg-ib0 /etc/sysconfig/network-scripts/ 
		;;
	*)
		echo "Wrong hostname, must be m1 or m2!"
		continue
		;;
	esac
	echo "192.168.1.1 m1" >> /etc/hosts 
	echo "192.168.1.2 m2" >> /etc/hosts
	echo "ssh-key will be generated next!"
	ssh-keygen -t rsa
}

function trust_config(){
	iptables -F
#	chkconfig iptables off
	systemctl disable firewalld
	systemctl stop firewalld
	setenforce 0
	echo "Set all service trust complete!"
	}

function login_config(){
	read -p "Confirm your IB network is all set(y/n): " confirm
	if [ "$confirm" = "n" ];then
		break

	fi
	hostname=`hostname`
	if [ "$hostname" == "m1" ];then
		an_server=m2
	else an_server=m1
		link_test=`ping $an_server -c 1 | grep "100% packet loss"`
		if [ "$link_test" != "" ];then
			echo -e "\033[31mConnection lost!\033[0m"
			read -p "Press any key to continue." i_am_sorry 
			continue
		else
#			echo "Attention, after execute step 1, "
			./scripts/ssh-env.sh
#			./scripts/ssh-login.sh
		fi
	fi
}

function login_config_bak(){
	cd scripts
	./lr_ssh.sh
	cd ..
	
}

function iperf_test(){
	hostname=`hostname`
	if [ "$hostname" == "m1" ];then
		an_server=m2
	else an_server=m1
	fi
	which iperf
	iperf_result=$?
	if [ "$result" == "1" ];then
		tar -xvf packages/iperf-2.0.5.tar.gz -C tmp
		cd tmp/iperf-2.0.5
		./configure
		make && make install
		cd ../..
	fi
	go=true
	while $go
	do
		read -p "Continue?(y/n) " check_go
		if [ "$check_go" == "y" ];then
			echo "1. iperf -s"
			echo "2. iperf -c $an_server -i 1 -t 43200"
			echo "3. iperf -s 512k"
			echo "4. iperf -c $an_server -w 512k -i 1 -t 43200"
			read -p "Select: " nu_go
			case $nu_go in 
			"1")
				iperf -s
				;;
			"2")
				iperf -c $an_server -i 1 -t 43200
				;;
			"3")
				iperf -s 512k
				;;
			"4")
				iperf -c $an_server -w 512k -i 1 -t 43200
				;;
			esac
		else
			go=false
		fi
	done
}


echo -e "\033[33m#### MAIN ####\033[0m"
echo

######### INITIALIZE ##########
env_prepare
red="\033[31m"
ori="\033[0m"
rbg="\033[41m"
yel="\033[33m"

########	ENV SET  ##########

gate_1=true
while $gate_1
do
	echo -e "\033[33mMENU\033[0m"
	echo 
	echo -e "\033[31m1. Driver install or upgrade;\033[0m"
	echo -e "\033[31m2. Reconfigure the network;\033[0m"
#	echo -e "\033[31m3. Service auto start;\033[0m"
	echo -e "\033[31m3. Shutdown the firewall and selinux;\033[0m"
	echo -e "\033[31m4. Setup RSA/DSA ssh login;\033[0m"
	echo -e "\033[31m5. Execute iperf test;\033[0m"
	echo -e "\033[31m6. Execute bandwidth test;\033[0m"
	echo -e "\033[31m7. Execute delay test;\033[0m"
	echo -e "\033[31m8. Exit.\033[0m"
	echo

	read -p "Select the number of item: " nu

	case $nu in
	"1")
		driver_select
		;;
	"2")
		network_config
		;;
	"3")
		trust_config
		;;
	"4")
		login_config	
		;;
	"5")
		iperf_test
		;;
	"6")
		mpirun -np 2 -machinefile /root/.mpd.hosts --allow-run-as-root -npernode 1 $mpi_dir/tests/osu*/osu_bw
		;;
	"7")
		mpirun -np 2 -machinefile /root/.mpd.hosts --allow-run-as-root -npernode 1 $mpi_dir/tests/osu_*/osu_latency		
		;;
	"8")
		break
		;;
	*)
		echo "You input the wrong number!"
		;;
	esac
	
	read -p "Back to the main menu(y/n): " gate_2
	if [ "$gate_2" = "n" ]; then
		gate_1=false
	fi
	
done

