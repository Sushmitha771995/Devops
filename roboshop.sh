#!bin/bash
#This is coding for the roboshop

service=$1
installation=$2


heading()
{
 echo -e "\e[1;4;35msetting up $1\e[0m"
}

heading
case $service in
frontend)
echo "installing nginx"
yum install nginx -y &>>logfile
case $? in
0)
  echo -e "\e[32mSUCCESS\e[0m"
  ;;
*)
  echo -e "\e[31mFAILURE\e[0m"
    ;;
esac

#systemctl enable nginx >>/dev/null
#systemctl start nginx
curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/a781da9c-8fca-4605-8928-53c962282b74/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
cd /usr/share/nginx/html
rm -rf *
unzip /tmp/frontend.zip
mv static/* .
rm -rf static README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf
systemctl restart nginx
;;
catalogue)
  heading
#echo -e "\e[1;4;35msentting up $1\e[0m"
echo "installing nodejs"
;;
cart)
  heading
#echo -e "\e[1;4;35msetting up cart\e[0m"
echo 'installing mongodb'
;;
*)
echo "not listed in service"
exit 1
;;
esac


