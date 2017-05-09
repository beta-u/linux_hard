if [ -f "/root/.ssh/id_rsa" ];then 
	echo -e "${yel}RSA key already configured."
	read -p "Do you want to generate a new one?(y/n) " new_key
	if [ "$new_key" == "n" ];then
		break
	fi
fi
./key_generate.exp
