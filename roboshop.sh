#!bin/bash

service=$1
LOG_FILE=/tmp/roboshop.log
echo -n -e "\e[4;31msetting up $service\e[0m"
status_check()
case $1 in
0)
  echo -e "\e[34mSUCCESS\e[0m"
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
  systemctl start nginx &>>$LOG_FILE
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
  yum install -y mongodb-org &>>$LOG_FILE
  status_check $?

echo -e "\e[32mUpdating ip address\e[0m"
sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf &>>$LOG_FILE
status_check $?

systemctl enable mongod &>>$LOG_FILE
status_check $?

systemctl start mongod &>>$LOG_FILE
status_check $?

echo -e "\e[32mDownload schema\e[0m"
curl -s -L -o /tmp/mongodb.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e9218aed-a297-4945-9ddc-94156bd81427/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"  &>>$LOG_FILE
status_check $?
cd /tmp
unzip -o mongodb.zip &>>$LOG_FILE
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

useradd roboshop &>>$LOG_FILE

case $? in
  9|0) status_check 0
    ;;
  *) status_check $?
    ;;
    esac

echo -e "\e[3232minstalling dependencies\e[0m"
curl -s -L -o /tmp/catalogue.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/1a7bd015-d982-487f-9904-1aa01c825db4/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
status_check $?
cd /home/roboshop
mkdir -p catalogue
cd catalogue
unzip -o /tmp/catalogue.zip
status_check $?
npm install
status_check $?

chown -R roboshop:roboshop /home/roboshop &>>$LOG_FILE
status_check $?

echo -e "\e[3232msetting up config files\e[0m"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
sed -i -e "s/MONGO_DNSNAME/mongodb-test.firstdevops.tk/" /etc/systemd/system/catalogue.service
systemctl daemon-reload &>>$LOG_FILE
status_check $?
systemctl start catalogue &>>$LOG_FILE
status_check $?
systemctl enable catalogue &>>$LOG_FILE
status_check $?
;;

redis)
 echo -e "\e[3232mInstalling redis\e[0m"
 yum install epel-release yum-utils -y &>>$LOG_FILE
 yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>>$LOG_FILE
 yum-config-manager --enable remi &>>$LOG_FILE
 yum install redis -y  &>>$LOG_FILE
 status_check $?
 echo -e "\e[3232mUpdate config files\e[0m"
 sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/redis.conf &>>$LOG_FILE
 status_check $?

 echo -e "\e[3232mStarting redis service\e[0m"
systemctl enable redis &>>$LOG_FILE
 status_check $?
systemctl start redis &>>$LOG_FILE
 status_check $?
;;
 user)
   echo -e "\e[3232minstalling node\e[0m"
yum install nodejs make gcc-c++ -y  &>>$LOG_FILE
status_check $?

useradd roboshop &>>$LOG_FILE

case $? in
  9|0) status_check 0
    ;;
  *) status_check $?
    ;;
    esac

echo -e "\e[3232, installing dependencies\e[0m"
curl -s -L -o /tmp/user.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/360c1f78-e8ed-41e8-8b3d-bdd12dc8a6a1/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
 status_check $?
 cd /home/roboshop &>>$LOG_FILE
 status_check $?
 mkdir -p user &>>$LOG_FILE
 status_check $?
 cd user &>>$LOG_FILE
 unzip -o /tmp/user.zip &>>$LOG_FILE
 status_check $?
 npm install  &>>$LOG_FILE
 status_check $?

chown -R roboshop:roboshop /home/roboshop &>>$LOG_FILE
status_check $?

echo -e "\e[3232msetting up config files\e[0m"
mv /home/roboshop/user/systemd.service /etc/systemd/system/user.service &>>$LOG_FILE
sed -i -e "s/MONGO_ENDPOINT/mongodb-test.firstdevops.tk/" /etc/systemd/system/user.service &>>$LOG_FILE
sed -i -e "s/REDIS_ENDPOINT/redis-test.firstdevops.tk/" /etc/systemd/system/user.service &>>$LOG_FILE
systemctl daemon-reload &>>$LOG_FILE
status_check $?
systemctl start user
#status_check $?
systemctl enable user &>>$LOG_FILE
#status_check $?
;;

cart)
  echo -e "\e[3232minstalling node\e[0m"
yum install nodejs make gcc-c++ -y  &>>$LOG_FILE
status_check $?

useradd roboshop &>>$LOG_FILE

case $? in
  9|0) status_check 0
    ;;
  *) status_check $?
    ;;
    esac

echo -e "\e[3232minstalling dependencies\e[0m"
curl -s -L -o /tmp/cart.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/d1ba7cbf-6c60-4403-865d-8a522a76cd76/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
status_check $?
cd /home/roboshop
mkdir -p cart
cd cart
unzip -o /tmp/cart.zip
status_check $?
npm install
status_check $?

chown -R roboshop:roboshop /home/roboshop &>>$LOG_FILE
status_check $?

echo -e "\e[3232msetting up config files\e[0m"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>$LOG_FILE
sed -i -e "s/CATALOGUE_ENDPOINT/catalogue-test.firstdevops.tk/" /etc/systemd/system/cart.service &>>$LOG_FILE
sed -i -e "s/REDIS_ENDPOINT/redis-test.firstdevops.tk/" /etc/systemd/system/cart.service &>>$LOG_FILE
systemctl daemon-reload &>>$LOG_FILE
status_check $?
systemctl start cart
#status_check $?
systemctl enable cart &>>$LOG_FILE
status_check $?
;;



*)
  echo -e "\e[31minvalied service\e[0m"
  exit 1
  ;;
esac

