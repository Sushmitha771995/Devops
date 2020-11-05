#!bin/bash
#This is coding for the roboshop

echo -e "\e[1;4;35msetting up $1\e[0m"
echo "installing nginx"
yum install nginx -y >> /dev/null
exit 100
echo $?
#echo -e "\e[1;4;35msentting up catalogue\e[0m"
#echo -e "\e[1;4;35msetting up cart\e[0m"
