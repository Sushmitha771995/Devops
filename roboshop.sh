#!bin/bash

service=$1
LOG_FILE=/tmp/roboshop.log
echo -n -e "\e[4;31msetting up $service\e[0m"
status_check()
case $1 in
0)
  echo -e "\e34mSUCCESS\e[0m"
  ;;
*)
  echo -e "\e31Failure\e\0m"
  ;;
esac

case $service in
frontend)
  echo -n -e "\e[32m installing nginx\e[0m"
  yum install nginx -y &>>$LOG_FILE
status_check $?
  echo -n -e "\e[32mDownload nginx docs\e[0m"
  curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/a781da9c-8fca-4605-8928-53c962282b74/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
  echo -n -e "\e[32m removing default and setting up configuration files\e[0m"
  status_check $?
  cd /usr/share/nginx/html
  rm -rf * &>>$LOG_FILE
  status_check $?
  unzip /tmp/frontend.zip &>>$LOG_FILE
  mv static/* . &>>$LOG_FILE
  rm -rf static README.md &>>$LOG_FILE
  status_check $?
  mv localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
  status_check $?
  echo -e "\e[32mstart ngnx service\e[0m"
  systemctl enable nginx &>>$LOG_FILE
  status_check $?
  systemctl restart nginx &>>$LOG_FILE
  status_check $?
  ;;
mongodb)
  echo -e "\e[32msetting up repos\e[0m"
  echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo
status_check $?

 echo -e "\e[32minstalling mongo\e[0m"
  yum install -y mongodb-org
  status_check $?

echo -e "\e[32mUpdating ip address\e[0m"
sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf &$LOG_FILE
status_check $?

echo -e "\e[32mDownload schema\e[0m"
cd /tmp
unzip mongodb.zip &>>$LOG_FILE
status_check $?
 mongo < catalogue.js &>>$$LOG_FILE
 status_check $?
 mongo < users.js  &>>$LOG_FILE
 status_check $?
;;

catalogue)

echo -e "\e[3232minstalling node\e[0m"
yum install nodejs make gcc-c++ -y  &>>$LOG_FILE
status_check $?

echo -e "\e[3232minstalling dependencies\e[0m"
curl -s -L -o /tmp/catalogue.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/1a7bd015-d982-487f-9904-1aa01c825db4/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
status_check $?
cd /home/roboshop
mkdir catalogue
cd catalogue
unzip /tmp/catalogue.zip &>>$LOG_FILE
status_check $?
npm install  &>>$LOG_FILE
status_check $?

chown -R roboshop:roboshop * &>>$LOG_FILE
status_check $?

echo -e "\e[3232msetting up config files\e[0m"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
systemctl daemon-reload &>>$LOG_FILE
status_check $?
systemctl start catalogue &>>$LOG_FILE
status_check $?
systemctl enable catalogue &>>$LOG_FILE
status_check $?
;;

*)
  echo -e "\e[31minvalied service\e[0m"
  exit 1
  ;;
esac

