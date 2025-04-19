#!/bin/bash/

USERID=$(id -u)

#Colors Declerations
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m" # By Default color (White Color) in shell script

#Logs Declerations
LOGS_FOLDER="/var/log/shell-script-logs/backend-log"
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

# Disable the existing Node Js module
dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling existing default NodeJS"

# Enable the existing Node Js 20 Version module
dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling NodeJS 20"

# Installing the existing Node Js module
dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing NodeJS"

# Creating the expense user
#useradd expense

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "Adding expense user"
else
    echo -e "expense user already exists ... $Y SKIPPING $N"
fi

#Creating the app directory
mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating app directory"

#Downloading the backend code
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading backend"

#Change the app directory
cd /app
rm -rf /app/* #Remove the existing files in inside of app folder

# Unzip the backend code
unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip backend"

#Installing npm for application dependencies
npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing dependencies"

# Creating the backend service and copy this backend service etc folder
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

# Prepare MySQL Schema

# Installing the mysql client
dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySQL Client"

# Setting transactions schema and tables in mysql client
mysql -h mysql.daws82s.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting up the transactions schema and tables"

# Daemon Reload
systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon Reload"

#Enabeling the backend service
systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling backend"

#Restarting the backend
systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting Backend"

