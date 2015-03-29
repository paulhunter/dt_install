
#!/bin/bash

# Day Trading - CSC 466
# Installation Script
# Usage
# ./install <SystemType>
# <SystemType> : 'tr' | 'lb' | 'ls' | 'qs'
# 	tr - Transaction Server
#	lb - Load Balancing Server
#   ls - Log Server
#   qs - Quote Server


clear
#Check that we have enough parameters
if [[ $# < 2 ]]; then
	echo "Too few parameters!"
    echo "  Usage: ./install.sh <Bitbucket Username> <System-Type>"
	exit
else
	if [[ $2 != "tr" && $2 != "lb" && $2 != "ls" && $2 != "qs" ]]; then
		echo "Incorrect System Type!"
        echo "Choices include:"
        echo "    tr - Transaction Server"
        echo "    lb - Load Balancer"
        echo "    ls - Log Server"
        echo "    qs - Quote Server"
		exit
	fi
fi

clear 
echo "Cleaning Past Install"
rm -rf /home/${USER}/postgres
rm -rf /home/${USER}/day_trading
rm -rf /home/${USER}/jdk

echo "+ ----------------------------------------------------------------- +"
echo "Fetching Source Codes"
mkdir /home/${USER}/day_trading
#Exec it so if it fails, we stop the script.
git clone "https://$1@bitbucket.org/romilkhanna/day-trading.git" /home/${USER}/day_trading
# User will be prompted for password.

if [[ ! -d "/home/${USER}/day_trading" ]] ; then
    echo "Bitbucket Authentication Failed, please try again"
    exit
fi

cd /home/${USER}/Desktop
mkdir dt_install
cd dt_install
echo "Fetching Postgres 9.4.1"
wget https://ftp.postgresql.org/pub/source/v9.4.1/postgresql-9.4.1.tar.gz
echo "Fetching Psycopg2"
wget http://initd.org/psycopg/tarballs/PSYCOPG-2-6/psycopg2-2.6.tar.gz
echo "Fetching Java SDK 8"
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u40-b26/jdk-8u40-linux-x64.tar.gz


echo "Unpacking Sources..."
tar xf postgresql-9.4.1.tar.gz
tar xf psycopg2-2.6.tar.gz

echo "+ ----------------------------------------------------------------- +"
echo "Fetching Configurations + Setup Scripts"
mkdir configs
wget https://raw.githubusercontent.com/paulhunter/dt_install/master/configs/pg_hba.conf -O ./configs/pg_hba.conf
wget https://raw.githubusercontent.com/paulhunter/dt_install/master/configs/postgresql.conf -O ./configs/postgresql.conf
wget https://raw.githubusercontent.com/paulhunter/dt_install/master/configs/createrole.sql -O ./configs/createrole.sql

echo "+ ----------------------------------------------------------------- +"
echo "Installing Postgres 9.4.1"
mkdir /home/${USER}/postgres
cd postgresql-9.4.1/
./configure --prefix=/home/${USER}/postgres/
make install
mkdir /home/${USER}/postgres/db
/home/${USER}/postgres/bin/initdb -D /home/${USER}/postgres/db
cd ../

echo "+ ----------------------------------------------------------------- +"
echo "Installing Psycopg2 2.6"
cd psycopg2-2.6 
python setup.py build_ext --pg-config=/home/${USER}/postgres/bin/pg_config 
python setup.py install --user
cd ../

echo "+ ----------------------------------------------------------------- +"
echo "Copying Default Network Configuration for Postgres"
cd configs
cp postgresql.conf /home/${USER}/postgres/db/postgresql.conf
cp pg_hba.conf /home/${USER}/postgres/db/pg_hba.conf
cd ../

echo "+ ----------------------------------------------------------------- +"
echo "Starting Postgres"
/home/${USER}/postgres/bin/pg_ctl start -D /home/${USER}/postgres/db
sleep 10 #give the server a second to start up.

echo "+ ----------------------------------------------------------------- +"
echo "Creating Database Role"
/home/${USER}/postgres/bin/psql postgres -p 3000 -f ./configs/createrole.sql

echo "+ ----------------------------------------------------------------- +"
echo "Installing Java SDK"
tar xf jdk-8u40-linux-x64.tar.gz
mv jdk1.8.0_40 ~/jdk

echo "+ ----------------------------------------------------------------- +"
echo "Updating PATH for JDK"
touch ~/.bash_profile
echo "export PATH=/home/${USER}/jdk/bin:/home/${USER}/postgres/bin:\$PATH" >> ~/.bash_profile
source ~/.bash_profile

echo "+ ----------------------------------------------------------------- +"
echo "Cleaning up Desktop"
cd ~/Desktop
rm -rf dt_install

echo "+ ----------------------------------------------------------------- +"
echo "Installation Complete"
echo "+ ----------------------------------------------------------------- +"




	
