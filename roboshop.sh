#!bin/bash
#This is coding for the roboshop

service=$1
case $service in
frontend)
echo -e "\e[1;4;35msetting up $1\e[0m"
;;
catalogue)
echo -e "\e[1;4;35msentting up $1\e[0m"
;;
esac

#echo "installing nginx"
#yum install nginx -y >> /dev/null
#echo -e "\e[1;4;35msentting up catalogue\e[0m"
#echo -e "\e[1;4;35msetting up cart\e[0m"
