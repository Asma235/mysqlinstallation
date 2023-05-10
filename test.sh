#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F)
LOG="mysqldbinstallation-${DATE}.log"
R="\e[31m"
G="\e[32m"
N="\e[0m"

VALIDATE(){
if [ $1 -ne 0 ]; then
        echo -e "$2 ... ${R} FAILURE ${N}" 2>&1 | tee -a $LOG
        exit 1
else
        echo -e "$2 ... ${G} SUCCESS ${N}" 2>&1 | tee -a $LOG
fi
}

if [ $USERID -ne 0 ]; then
        echo -e "${R} You need to be root user to execute this script ${N}"
        exit 1
fi

apt-get update -y >> $LOG
VALIDATE $? "Updating package"

apt-get install mysql-server -y >> $LOG
VALIDATE $? "installing mysql-server"

systemctl status mysql.service >> $LOG
VALIDATE $? "running mysql"

# Set MySQL credentials
#echo -n "Enter Username:${1} "
#read -s DB_USER
#echo
#echo -n "Enter Password:${2} "
#read -s DB_PASS
#echo
DB_USER=$1
DB_PASS=$2
# Create MySQL user
CREATE_USER="CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'; GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"
mysql -u root -e "${CREATE_USER}" >> $LOG
VALIDATE $? "creating mysql user '${DB_USER}'"

# Grant privileges to user
#GRANT_PRIVILEGES="GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost';"
#mysql -"${GRANT_PRIVILEGES}" >> $LOG
VALIDATE $? "granting privileges to mysql user '${DB_USER}'"

# Test MySQL connection
mysql -u $DB_USER -p$DB_PASS -e "SHOW DATABASES;" >> $LOG
VALIDATE $? "connecting to mysql server with user '${DB_USER}'"

echo "MySQL installation complete"

