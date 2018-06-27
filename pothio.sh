#!/bin/bash
echo	"#########################################
#	Create your dns simplily	#
#	   by script pothioDns		#
#########################################"
echo "___________________     __ "
echo "____________  _____|    |_| "
echo "| ___  \    | || |_____ __  "
echo "| |_/  /-_-_| || |_____ | |  "__
echo "|  __/ /   \| || ____  || | /   \ "
echo "| |   | ( ) | || |   | || || ( ) |"
echo "\_|--- \___/|_||_|   |_/\_/ \___/ "
#Function corp
body(){
        echo "@         IN      SOA     $dns root.$hostDns(
                                2
                                604800
                                86400
                                2419200
                                604800 )
        ;" >> $file
}

ip=
dns=
hostDns=
root="/etc/bind"
chk=
invseDns=
nameFile=

#begin the creation of file db.directe
if [ -e $root ];then
        echo "give your DNS without www"
        read dns
        echo "give your IP address of Class A"
        read ip
	
	invseDns=$( echo $ip | tr "." " ")
	nameFile=$( echo $dns | tr "." " ")

        set $nameFile

	#create file db.mydns.directe
	if [ ! -e $root/db.$1.directe ];then
	
		hostDns="$HOSTNAME.$dns."
		file="$root/db.$1.directe"

		body
       		echo "@       IN      NS      $hostDns" >> $file
        	echo "@       IN      A       $ip" >> $file
        	echo "$HOSTNAME  IN  	 A       $ip" >> $file
		chk=1
	else
		echo "file db.directe already exist"
	fi
	
	#create file db.mydns.inverse
	if [ ! -e $root/db.$1.inverse ];then
		file="$root/db.$1.inverse"

                set $invseDns

		body
        	echo "@         IN      NS      $hostDns" >> $file
        	echo "$4         IN      PTR     $hostDns" >> $file
		chk=1
	fi
	
	 
        set $nameFile
	file=$root/named.conf.default-zones

	echo " " >> $file	
	echo "zone \"$dns\"{" >> $file
	echo "	type master;" >> $file
	echo "	file \"$root/db.$1.directe\";" >> $file
	echo "};" >> $file
	
	set $invseDns

	echo " " >> $file	
        echo "zone \"$3.$2.$1.in-addr.arpa\"{" >> $file
        echo "  type master;" >> $file
	set $nameFile
        echo "  file \"$root/db.$1.inverse\";" >> $file
        echo "};" >> $file
	
	echo "bind9 restart"
	/etc/init.d/bind9 restart

	if [ "$chk" -eq 1 ];then
		echo "files created:"
		echo "	$root/db.$1.directe" 
		echo "	$root/db.$1.invese"
	fi
	
	echo " "
	echo "Go to see file: /etc/resolv.conf"
	echo "After you can test your DNS like nslook"
	echo " "
	
	#Creation of underDomain

	echo "If you want to create under domain 1/0"
	read c
	
	#Create subdomain
	if [ "$c" -eq 1 ];then
		echo "give the DNS without www"
		read UdDns
		
		nameFile=$( echo $UdDns | tr "." " ")
        	set $nameFile

		file="$root/db.$1.directe"
		hostDns="$HOSTNAME.$UdDns."

		body
		echo "@       IN      NS      $hostDns" >> $file
                echo "@       IN      A       $ip" >> $file
                echo "$HOSTNAME  IN      A       $ip" >> $file

		file=$root/named.conf.default-zones

       		echo " " >> $file
        	echo "zone \"$UdDns\"{" >> $file
        	echo "  type master;" >> $file
        	echo "  file \"$root/db.$1.directe\";" >> $file
        	echo "};" >> $file	
		
		nameFile=$( echo $dns | tr "." " ")
		set $nameFile
		file="$root/db.$1.inverse"

                echo "$HOSTNAME.$UdDns         IN      NS      $hostDns" >> $file
		set $invseDns
                echo "$4         IN      PTR     $hostDns" >> $file

		echo "bind9 restart"
        	/etc/init.d/bind9 restart

	fi

else
	echo "Please install bind9"
fi
