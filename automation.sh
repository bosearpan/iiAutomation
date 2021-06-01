#!/bin/bash
#===========================Apache Installation=================================================================================
sudo apt update -y &> /dev/null
dpkg -s apache2 &> /dev/null
if [ $? -ne 0 ]
then
echo "Installing apache"
sudo apt-get install apache2 &> /dev/null
fi
sudo service apache2 status | grep "running" &> /dev/null 	 #Ensure that the apache2 service is running.
if [ $? -ne 0 ]
then
sudo systemctl enable apache2                 				 #Ensure that the apache2 service is enabled
sudo systemctl start apache2.service
fi
#===========================Backup apache log ==================================================================================
s3_bucket="upgrad-arpan"
myname="Arpan"
timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2/
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar *.log &> /dev/null
size=$(sudo du -sh /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}')
#============================ Bookeep ===========================================================================================
if [ -e /var/www/html/inventory.html ]
then
echo "<br>httpd-logs &nbsp;&nbsp;&nbsp; ${timestamp} &nbsp;&nbsp;&nbsp; tar &nbsp;&nbsp;&nbsp; ${size}" >> /var/www/html/inventory.html
else
echo "<b>Log Type &nbsp;&nbsp;&nbsp;&nbsp; Date Created &nbsp;&nbsp;&nbsp;&nbsp; Type &nbsp;&nbsp;&nbsp;&nbsp; Size</b><br>" > /var/www/html/inventory.html
echo "<br>httpd-logs &nbsp;&nbsp;&nbsp; ${timestamp} &nbsp;&nbsp;&nbsp; tar &nbsp;&nbsp;&nbsp; ${size}" >> /var/www/html/inventory.html
fi
#============================Pushing to AWS S3 bucket============================================================================
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar &> /dev/null
#=============================Cron Job to run the script everyday================================================================
if [ ! -e /etc/cron.d/automation ]
then
sudo touch /etc/cron.d/automation
sudo echo "0 0 * * *	root	/root/Automation_Project/automation.sh --crond" | sudo tee -a /etc/cron.d/automation > /dev/null
fi
#++++++++++++++++++++++++++++++++++End of Play+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++i
