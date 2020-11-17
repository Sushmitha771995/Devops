#!bin/bash

service=$1
LOG_FILE=/tmp/roboshop.log
echo  -e "\e[4;31msetting up $service\e[0m"
status_check()
{
case $1 in
0)
  echo -e "\e[34mSUCCESS\e[0m"
  ;;
*)
  echo -e "\e31Failure\e\0m"
  ;;
esac
}

app_user()
{
  useradd roboshop &>>$LOG_FILE

case $? in
  9|0) status_check 0
    ;;
  *) status_check $?
    ;;
    esac
}


node_js()
{
echo -n -e "\e[3232minstalling node\e[0m\t\t"
yum install nodejs make gcc-c++ -y  &>>$LOG_FILE
status_check $?

#useradd roboshop &>>$LOG_FILE
app_user
case $? in
  9|0) status_check 0
    ;;
  *) status_check $?
    ;;
    esac

echo -n  -e "\e[3232minstalling dependencies\e[0m\t\t"
curl -s -L -o /tmp/$service.zip "$1" &>>$LOG_FILE
status_check $?
cd /home/roboshop
mkdir -p $service
cd $service
unzip -o /tmp/$service.zip
status_check $?
npm install
status_check $?

chown -R roboshop:roboshop /home/roboshop &>>$LOG_FILE
status_check $?

echo -n -e "\e[3232msetting up config files\e[0m\t\t"
mv /home/roboshop/$service/systemd.service /etc/systemd/system/$service.service &>>$LOG_FILE
sed -i -e "s/CATALOGUE_ENDPOINT/catalogue-test.firstdevops.tk/"  -e "s/REDIS_ENDPOINT/redis-test.firstdevops.tk/"  -e "s/MONGO_DNSNAME/mongodb-test.firstdevops.tk/"  -e "s/REDIS_DNSNAME/redis-test.firstdevops.tk/" -e "s/MONGO_ENDPOINT/mongodb-test.firstdevops.tk/" -e "s/DBHOST/sql-test.firstdevops.tk/" -e "s/CART_ENDPOINT/cart-test.firstdevops.tk/" /etc/systemd/system/$service.service &>>$LOG_FILE
sed -i -e "s/CARTHOST/cart-test.firstdevops.tk/" -e "s/USERHOST/user-test.firstdevops.tk/" "s/AMQPHOST/rabbitmq-test.firstdevops.tk/" /etc/systemd/system/$service.service &>>$LOG_FILE
status_check $?
systemctl daemon-reload &>>$LOG_FILE
status_check $?
systemctl start $service &>>$LOG_FILE
status_check $?
systemctl enable $service &>>$LOG_FILE
status_check $?

}
uid=$(id -u)
if [ $uid -ne 0 ];
then
  echo -e "\e[1;31mYou should be a sudo / root user to execute this script\e[0m"
  exit 2
fi

set-hostname $service
disable-auto-shutdown

case $service in
frontend)
  echo -n -e "\e[32mInstalling nginx\e[0m\t\t\t"
  yum install nginx -y &>>$LOG_FILE
status_check $?
  echo -n -e "\e[32mDownload nginx docs\e[0m\t\t\t"
  curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/a781da9c-8fca-4605-8928-53c962282b74/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
status_check $?
  echo -n -e "\e[32mSetting up config files\e[0m\t\t\t"
  cd /usr/share/nginx/html
  rm -rf * &>>$LOG_FILE
  unzip /tmp/frontend.zip &>>$LOG_FILE
  mv static/* . &>>$LOG_FILE
  rm -rf static README.md &>>$LOG_FILE
  mv localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
  status_check $?

  echo -n -e "\e[32mstart nginx service\e[0m\t\t\t"
  systemctl enable nginx &>>$LOG_FILE
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

node_js "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/1a7bd015-d982-487f-9904-1aa01c825db4/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"

;;

 user)
node_js

app_user

echo -e "\e[3232, installing dependencies\e[0m"
curl -s -L -o /tmp/user.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/360c1f78-e8ed-41e8-8b3d-bdd12dc8a6a1/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
 status_check $?
 node_js
;;

cart)
node_install
app_user

echo -e "\e[3232minstalling dependencies\e[0m"
curl -s -L -o /tmp/cart.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/d1ba7cbf-6c60-4403-865d-8a522a76cd76/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
status_check $?
node_js
;;
shipping)
  echo -e "\e[3232mInstall maven\e[0m"
yum install maven -y
  
app_user

echo -e "\e[3232minstalling dependencies\e[0m"
curl -s -L -o /tmp/shipping.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/1ebc164b-f649-49b5-807d-2e55dc14628e/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
status_check $?
node_js
;;

mysql)
  echo -e "\e[3232msetting up mysql repos\e[0m"
echo '[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/mysql.repo
status_check $?


echo -e "\e[3232mInstalling mmysql\e[0m"
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

  echo -e "\e[3232mInstalling dependencies\e[0m"
  yum install https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_22.2.1-1~centos~7_amd64.rpm -y  &>>$LOG_FILE

echo -e "\e[3232mSetting up repos\e[0m"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$LOG_FILE
status_check $?

echo -e "\e[3232mInstalling rabbitmq \e[0m"
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
 echo -n "dependecny installation"
  yum install python36 gcc python3-devel -y &>>$LOG_FILE

app_user

echo -e "\e[3232minstalling dependencies\e[0m"
curl -L -s -o /tmp/payment.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/64e9a902-e729-44ad-a562-8f605ae9617e/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>>$LOG_FILE
status_check $?
node_js
;;

*)
  echo -e "\e[31minvalied service\e[0m"
  exit 1
  ;;
esac

