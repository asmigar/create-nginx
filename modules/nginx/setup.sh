#!/bin/bash
sudo yum install nginx -y
sed -i 's/Welcome to nginx/Welcome to Asmigar/' /usr/share/nginx/html/index.html
systemctl start nginx