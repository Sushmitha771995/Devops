#!/bin/bash

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
  echo -e "\t\t\t\t  \e[31mFAILURE\e[0m"
  echo "Refer $LOG_FILE for more details"
  ;;
esac
}
heading $service

case $service in
frontend)
echo -n "installing nginx  "
yum install nginx -y &>>$LOG_FILE
status_check $?

echo -n "Downloading frontend  "
curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/a781da9c-8fca-4605-8928-53c962282b74/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" >>$LOG_FILE
status_check $?

echo -n "Clearing old docs  "
cd /usr/share/nginx/html
rm -rf *
status_check $?

echo -n "extacting frontend   "
unzip /tmp/frontend.zip &>>$LOG_FILE
status_check $?

mv static/* .
rm -rf static README.md

echo -n "Update ngnx configuration"
mv localhost.conf /etc/nginx/default.d/roboshop.conf
status_check $?

systemctl enable nginx &>>$LOG_FILE
systemctl restart nginx &>>$LOG_FILE
;;

mongodb)
echo -n "updating mongo repos "

 echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo &>>$LOG_FILE
 status_check $?

echo -n "instaling mongo\t\t"
sudo yum install -y mongodb-org &>>$LOG_FILE
status_check $?

echo -n "changing IP address "
sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf &>>LOG_FILE
status_check $?

systemctl enable mongod &>>$LOG_FILE
status_check $?

systemctl start mongod &>>$LOG_FILE
status_check $?

echo -n "extracting schema"
curl -s -L -o /tmp/mongodb.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e9218aed-a297-4945-9ddc-94156bd81427/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
status_check $?

echo -n "extractig confifuration files"
cd /tmp &>>$LOG_FILE
unzip -o mongodb.zip &>>$LOG_FILE
status_check $?

echo -n "load catalogue app schema"
mongo < catalogue.js  &>>$LOG_FILE
status_check $?

echo -n "load user app schema "
mongo < users.js &>>$LOG_FILE
status_check $?
;;

catalogue)
  echo -n "installing nodejs"
  yum install nodejs make gcc-c++ -y  &>>$LOG_FILE
  status_check $?

  echo -n "adding user\t"
  useradd roboshop &>>$LOG_FILE

  case $? in
  9|0) status_check 0
    ;;
  *) status_check $?
    ;;
    esac

    echo -n "downloading configuration files"
  curl -s -L -o /tmp/catalogue.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/1a7bd015-d982-487f-9904-1aa01c825db4/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$Downloading
 status_check $?

echo -n "extracting catalogue file"
 cd /home/roboshop &>>$LOG_FILE
 mkdir catalogue  &>>$LOG_FILE
 cd catalogue &>>$LOG_FILE
 unzip /tmp/catalogue.zip &>>$LOG_FILE
 status_check $?

echo -n "Download dependent packages"
npm install  $>>LOG_FILE
status_check $?

echo -n "Start system service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
status_check $?
systemctl daemon-reload &>>$LOG_FILE
status_check $?
systemctl start catalogue &>>$LOG_FILE
status_check $?
systemctl enable catalogue &>>$LOG_FILE

;;
*)
echo -n "not listed in service"
exit 1
;;
esac


