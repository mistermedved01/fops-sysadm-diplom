#!/bin/bash

wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb
sudo apt update -y

sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y
sudo apt install mysql-server -y

sudo mysql -uroot -e "create user zabbixUser@localhost identified by 'ZAQ1xsw2';"
sudo mysql -uroot -e "create database zabbixDB character set utf8 collate utf8_bin;" 
sudo mysql -uroot -e "grant all privileges on zabbixDB.* to zabbixUser@localhost;"
sudo mysql -uroot -e "FLUSH PRIVILEGES;"

sudo mysql -uroot -e "set global log_bin_trust_function_creators = 1;"
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql -u zabbixUser -p'ZAQ1xsw2' zabbixDB
sudo mysql -uroot -e "set global log_bin_trust_function_creators = 0;"

sudo cp /tmp/zabbix_server.conf /etc/zabbix

sudo systemctl restart zabbix-server zabbix-agent apache2 
sudo systemctl enable zabbix-server zabbix-agent apache2