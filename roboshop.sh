#!bin/bash
#This is coding for the roboshop

service=$1
case $service in
frontend)
echo -e "\e[1;4;35msetting up $1\e[0m"
echo "installing nginx"
yum install nginx -y >> /dev/null
;;
catalogue)
echo -e "\e[1;4;35msentting up $1\e[0m"
echo "installing nodejs"
;;
cart)
echo -e "\e[1;4;35msetting up cart\e[0m"
echo 'installing mongodb'
;;
esac


