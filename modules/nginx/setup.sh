#!/bin/bash
sudo amazon-linux-extras install nginx1 -y
sed -i 's/Welcome to nginx/Welcome to Asmigar/' /usr/share/nginx/html/index.html
systemctl start nginx