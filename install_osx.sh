
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
rm -rf /Users/${USER}/postgres
rm -rf /Users/${USER}/day_trading
rm -rf /Users/${USER}/jdk

echo "+ ----------------------------------------------------------------- +"
echo "Fetching Source Codes"
mkdir /Users/${USER}/day_trading
#Exec it so if it fails, we stop the script.
git clone "https://$1@bitbucket.org/romilkhanna/day-trading.git" /Users/${USER}/day_trading
# User will be prompted for password.

if [[ ! -d "/Users/${USER}/day_trading" ]] ; then
    echo "Bitbucket Authentication Failed, please try again"
    exit
fi

cd /Users/${USER}/Desktop
mkdir dt_install
cd dt_install
echo "Fetching Postgres 9.4.1"
curl -o postgresql-9.4.1.tar.gz https://ftp.postgresql.org/pub/source/v9.4.1/postgresql-9.4.1.tar.gz
echo "Fetching Psycopg2"
curl -o psycopg2-2.6.tar.gz http://initd.org/psycopg/tarballs/PSYCOPG-2-6/psycopg2-2.6.tar.gz
echo "Fetching Java SDK 8"
curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" -o jdk-8u40-macosx-x64.dmg http://download.oracle.com/otn-pub/java/jdk/8u40-b27/jdk-8u40-macosx-x64.dmg


echo "Unpacking Sources..."
gunzip postgresql-9.4.1.tar.gz
tar xf postgresql-9.4.1.tar
gunzip psycopg2-2.6.tar.gz
tar xf psycopg2-2.6.tar

echo "+ ----------------------------------------------------------------- +"
echo "Fetching Configurations + Setup Scripts"
mkdir configs
curl -o ./configs/pg_hba.conf https://raw.githubusercontent.com/paulhunter/dt_install/master/configs/pg_hba.conf
curl -o ./configs/postgresql.conf https://raw.githubusercontent.com/paulhunter/dt_install/master/configs/postgresql.conf
curl -o ./configs/createrole.sql https://raw.githubusercontent.com/paulhunter/dt_install/master/configs/createrole.sql

echo "+ ----------------------------------------------------------------- +"
echo "Installing Postgres 9.4.1"
mkdir /Users/${USER}/postgres
cd postgresql-9.4.1/
./configure --prefix=/Users/${USER}/postgres/
make install
mkdir /Users/${USER}/postgres/db
/Users/${USER}/postgres/bin/initdb -D /Users/${USER}/postgres/db
cd ../

echo "+ ----------------------------------------------------------------- +"
echo "Installing Psycopg2 2.6"
cd psycopg2-2.6 
python setup.py build_ext --pg-config=/Users/${USER}/postgres/bin/pg_config 
python setup.py install --user
cd ../

echo "+ ----------------------------------------------------------------- +"
echo "Copying Default Network Configuration for Postgres"
cd configs
cp postgresql.conf /Users/${USER}/postgres/db/postgresql.conf
cp pg_hba.conf /Users/${USER}/postgres/db/pg_hba.conf
cd ../

echo "+ ----------------------------------------------------------------- +"
echo "Starting Postgres"
/Users/${USER}/postgres/bin/pg_ctl start -D /Users/${USER}/postgres/db
sleep 10 #give the server a second to start up.

echo "+ ----------------------------------------------------------------- +"
echo "Creating Database Role"
/Users/${USER}/postgres/bin/psql postgres -p 3000 -f ./configs/createrole.sql

echo "+ ----------------------------------------------------------------- +"
echo "Installing Java SDK"
echo "Mounting SDK"
hdiutil attach ./jdk-8u40-macosx-x64.dmg
echo "Expanding Package"
pkgutil --expand /Volumes/JDK\ 8\ Update\ 40/JDK\ 8\ Update\ 40.pkg ./up_jdk
cd up_jdk
cpio -i < ./jdk18040.pkg/Payload
echo "Moving into place"
mv ./Contents/Home /Users/${USER}/jdk
cd ../

echo "+ ----------------------------------------------------------------- +"
echo "Updating PATH for JDK"
touch ~/.bash_profile
echo "export PATH=/Users/${USER}/jdk/bin:/Users/${USER}/postgres/bin:\$PATH" >> ~/.bash_profile
source ~/.bash_profile

echo "+ ----------------------------------------------------------------- +"
echo "Cleaning up Desktop"
cd ~/Desktop
rm -rf dt_install

echo "+ ----------------------------------------------------------------- +"
echo "Installation Complete"
echo "+ ----------------------------------------------------------------- +"




	
