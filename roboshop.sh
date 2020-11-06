#!bin/bash

#This is coding for the roboshop

service=$1
LOG_FILE=/tmp/roboshop.log

heading()
{
 echo -e "\e[1;4;35msetting up $1\e[0m"
}
status_check()
{
 case $1 in
0)
  echo -e "\t\t\t\\t \e[32mSUCCESS\e[0m"
  ;;
*)
  echo -e "\t\t\t\t\ \e[31mFAILURE\e[0m"
  echo "Refer $LOG_FILE for more details"
  ;;
esac
}

heading
case $service in
frontend)
echo -n "installing nginx"
yum install nginx -y &>>$LOG_FILE
status_check $?
echo -n "Downloading frontend "
curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/a781da9c-8fca-4605-8928-53c962282b74/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" >>$LOG_FILE
status_check $?
echo "Clearing old docs"
cd /usr/share/nginx/html
rm -rf *
status_check $?
echo "extacting frontend"
unzip /tmp/frontend.zip &>>$LOG_FILE
status_check $?

mv static/* .
rm -rf static README.md

echo "Update ngnx configuration"


mv localhost.conf /etc/nginx/default.d/roboshop.conf
status_check $?

systemctl enable nginx &>>$LOG_FILE
systemctl restart nginx &>>$LOG_FILE

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


