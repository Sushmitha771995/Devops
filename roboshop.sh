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
systemctl start nginx &>>$LOG_FILE
;;

mongodb)
echo -n "updating mongo repos "

 echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo
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
  curl -s -L -o /tmp/catalogue.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/1a7bd015-d982-487f-9904-1aa01c825db4/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
 status_check $?

echo -n "extracting catalogue file"
 cd /home/roboshop
 mkdir -p catalogue
 cd catalogue
 unzip -o /tmp/catalogue.zip &>>$LOG_FILE
 status_check $?

echo -n "Download dependent packages"
npm install &>>$LOG_FILE
status_check $?

chown roboshop:roboshop /home/roboshop -R

echo -n "Start system service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
sed -i -e "s/MONGO_DNSNAME/mongodb-test.firstdevops.tk/" /etc/systemd/system/catalogue.service &>>$LOG_FILE
systemctl daemon-reload &>>$LOG_FILE
status_check $?

status_check $?
systemctl start catalogue &>>$LOG_FILE
status_check $?
systemctl enable catalogue &>>$LOG_FILE
;;

redis)
  echo -n "Install packages"
  yum install epel-release yum-utils -y &>>$LOG_FILE
  yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>>$LOG_FILE
  yum-config-manager --enable remi &>>$LOG_FILE
  yum install redis -y &>>$LOG_FILE
  status_check $?
  echo -n "changing ip confifuration"
  sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/redis.conf  &>>$LOG_FILE
  status_check $?

  systemctl enable redis
  status_check $?
  systemctl start redis
  status_check $?
;;

user)
echo -n "installing node js"
yum install nodejs make gcc-c++ -y  &>>LOG_FILE
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
 curl -s -L -o /tmp/user.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/360c1f78-e8ed-41e8-8b3d-bdd12dc8a6a1/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE

status_check $?

echo -n "extracting user file"
 cd /home/roboshop
 mkdir -p user
 cd user
 unzip -o /tmp/user.zip &>>$LOG_FILE
 status_check $?

echo -n "Download dependent packages"
npm install &>>$LOG_FILE
status_check $?

chown roboshop:roboshop /home/roboshop/user -R

echo -n "Start system service"
mv /home/roboshop/user/systemd.service /etc/systemd/system/user.service &>>$LOG_FILE
sed -i -e "s/MONGO_ENDPOINT/mongodb-test.firstdevops.tk/" /etc/systemd/system/user.service &>>$LOG_FILE
sed -i -e "s/REDIS_ENDPOINT/redis-test.firstdevops.tk/" /etc/systemd/system/user.service &>>$LOG_FILE
systemctl daemon-reload &>>$LOG_FILE
status_check $?

systemctl start user &>>$LOG_FILE
status_check $?
systemctl enable user &>>$LOG_FILE
;;

cart)
echo -n "installing node js"
yum install nodejs make gcc-c++ -y  &>>LOG_FILE
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
 curl -s -L -o /tmp/cart.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/d1ba7cbf-6c60-4403-865d-8a522a76cd76/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
 status_check $?

echo -n "extracting cart file"
 cd /home/roboshop
 mkdir -p cart
 cd cart
 unzip -o /tmp/cart.zip &>>$LOG_FILE
 status_check $?

echo -n "Download dependent packages"
npm install &>>$LOG_FILE
status_check $?

chown roboshop:roboshop /home/roboshop/cart -R

echo -n "Start system service"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service

sed -i -e "s/CATALOGUE_ENDPOINT/catalogue-test.firstdevops.tk/" /etc/systemd/system/cart.service &>>$LOG_FILE
sed -i -e "s/REDIS_ENDPOINT/redis-test.firstdevops.tk/" /etc/systemd/system/cart.service &>>$LOG_FILE
systemctl daemon-reload &>>$LOG_FILE
status_check $?

systemctl start cart &>>$LOG_FILE
status_check $?
systemctl enable cart &>>$LOG_FILE
;;

shipping)
  echo -n "installing maven"
  yum install maven -y &>>$LOG_FILE
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
 curl -s -L -o /tmp/shipping.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/1ebc164b-f649-49b5-807d-2e55dc14628e/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
 status_check $?

echo -n "extracting shiping file"
 cd /home/roboshop
 mkdir -p shipping
 cd shipping
 unzip -o /tmp/shipping.zip &>>$LOG_FILE
 status_check $?

 echo -n "packaging "
mvn clean package  &>>$LOG_FILE
 mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
 status_check $?
 cp /home/roboshop/shipping/systemd.service /etc/systemd/system/shipping.service &>>$LOG_FILE
  status_check $?

 sed -i -e "s/CARTENDPOINT/cart-test.firstdevops.tk/" /etc/systemd/system/shipping.service &>>$LOG_FILE

systemctl daemon-reload &>>$LOG_FILE
status_check $?

systemctl start shipping &>>$LOG_FILE
status_check $?
systemctl enable shipping &>>$LOG_FILE
;;

mysql)

    echo "Setup repository\t"
    echo '[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/mysql.repo
    status_check $?

    echo "Install MySQL\t\t"
    yum remove mariadb-libs -y &>>$LOG_FILE
    yum install mysql-community-server -y &>>$LOG_FILE
    status_check $?

    echo "Start MySQL\t\t"
    systemctl enable mysqld &>>$LOG_FILE
    systemctl start mysqld &>>$LOG_FILE
    status_check $?

    echo "show databases;" | mysql -uroot -ppassword &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        sleep 30
        MYSQL_DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
        echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyPassw0Rd@1';
uninstall plugin validate_password;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';" >/tmp/reset.sql

        echo "Reset Password\t"
        mysql --connect-expired-password -uroot -p$MYSQL_DEFAULT_PASSWORD </tmp/reset.sql  &>>$LOG_FILE
        status_check $?
    fi

    echo "Download Schema\t\t"
    curl -s -L -o /tmp/mysql.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/2a75b631-2da9-4ced-810e-8b3a8761729d/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
    status_check $?

    echo "Load Schema\t\t"
    cd /tmp
    unzip -o mysql.zip &>>$LOG_FILE
    mysql -u root -ppassword <shipping.sql &>>$LOG_FILE
    status_check $?
    ;;
rabbitmq)
  echo -n " installing python package"
yum install https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_22.2.1-1~centos~7_amd64.rpm -y &>>$LOG_FILE
status_check $?
echo -n "Setup YUM repositories for RabbitMQ"
 curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$LOG_FILE
status_check $?

echo -n "Install RabbitMQ"
yum install rabbitmq-server -y &>>$LOG_FILE
status_check $?

echo -n "Start RabbitMQ"
systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
status_check $?

echo -n "Create application user"
rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqctl set_user_tags roboshop administrator &>>$LOG_FILE
 rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
 status_check $?

;;

payment)
  echo -n "nstalling python 3"
  yum install python36 gcc python3-devel -y &>>$LOG_FILE
status_check $?

echo -n "adding user\t"
  useradd roboshop &>>$LOG_FILE

  case $? in
  9|0) status_check 0
    ;;
  *) status_check $?
    ;;
    esac

echo -n "Download the repo"
 cd /home/roboshop
 curl -L -s -o /tmp/payment.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/64e9a902-e729-44ad-a562-8f605ae9617e/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
 mkdir -p payment
 cd payment
 unzip /tmp/payment.zip &>>$LOG_FILE
 status_check $?


echo -n "Install the dependencies"
 cd /home/roboshop/payment
 pip3 install -r requirements.txt


#Update the roboshop user and group id in payment.ini file.
chown roboshop:roboshop /home/roboshop/payment -R

# mv /home/roboshop/payment/systemd.service /etc/systemd/system/payment.service
# systemctl daemon-reload
# systemctl enable payment
# systemctl start payment
*)
echo -n "not listed in service"
exit 1
;;
esac


