#!/bin/bash

# To do a fresh deployment or rerun the setup process.
sudo systemctl stop my_web_app
sudo systemctl disable my_web_app
sudo rm /etc/systemd/system/my_web_app.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
sudo rm /etc/nginx/sites-enabled/my_web_app
sudo rm /etc/nginx/sites-available/my_web_app
sudo nginx -t
sudo systemctl reload nginx
