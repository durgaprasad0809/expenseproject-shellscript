#!/bin/bash/

USERID=$(id -u)

#Colors Declerations
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m" # By Default color (White Color) in shell script

#Logs Declerations
LOGS_FOLDER="/var/log/shell-script-logs/database-log"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

# Creating the Validate Function using shell scripting
VALIDATE(){
    if($1 -ne 0)
    then
       echo -e "$2 ... $R Faliaure $N"
       exit 1
    else
        echo -e "$2 ... $G Success $N"
    fi
}

# Creating Function using shell script
CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}

# Creating database log folder
mkdir -p $LOGS_FOLDER
echo "Database log file is created"

echo "Script Started executing at::$TIMESTAMP" &>>$LOG_FILE_NAME

echo "Current User id is ::" ${USERID} # Normal User Id is 1001 and Sudo User Id is 0

CHECK_ROOT # Calling the Check root function with out  any input args

#Install MySQL Server
dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing the My Sqlserver"

# enable MySQL Service
systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabeling the My Sql service"

# Start MySQL Service
systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Start the My Sql service"

#mysql_secure_installation --set-root-pass ExpenseApp@1

# To Handling Reset Password Logic
mysql -h mysql.daws82s-durga.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo "MySQL Root password not setup" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting Root Password"
else
    echo -e "MySQL Root password already setup ... $Y SKIPPING $N"
fi
