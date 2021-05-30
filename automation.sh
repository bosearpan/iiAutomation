#!/bin/bash
#Perform an update of the package details and the package list at the start of the script.
sudo apt update -y
#Install the apache2 package if it is not already installed.
dpkg -s apache2 &> /dev/null
while [ $? -ne 0 ]
do
sudo apt-get install apache2
done
sudo service apache2 status | grep "running"  #Ensure that the apache2 service is running.
if [ $? -ne 0 ]
then
sudo systemctl enable apache2                  #Ensure that the apache2 service is enabled
sudo systemctl start apache2.service
fi
#Create a tar archive of apache2 access logs and error logs that are present in the /var/log/apache2/ directory and place the tar into the /tmp/ directory
s3_bucket="upgrad-arpan"
myname="Arpan"
timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2/
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar *.log

#The script should run the AWS CLI command and copy the archive to the s3 bucket.
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
