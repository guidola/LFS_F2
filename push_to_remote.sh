#!/usr/bin/env bash

# $1 holds the server ip
# $1 holds the target port
# this script must be executed from the sources root

#remove existing files on target directory
ssh -p $2 lfs@${1} -t 'sudo rm -rf /web_server/*'

# scp all project files to /web_server
ssh -p $2 lfs@${1} -t 'sudo rm -rf /home/lfs/temp; mkdir -pv /home/lfs/temp'
scp -r ./* lfs@${1}:/home/lfs/temp
ssh -p $2 lfs@${1} -t 'sudo mv /home/lfs/temp/* /web_server/'

# ssh -p $2 execute several setup commands
# change ownership of files to apache user
ssh -p $2 lfs@${1} -t 'sudo chown apache:apache -R /web_server/'
# add execution privileges to cgi files
ssh -p $2 lfs@${1} -t 'sudo chmod +x /web_server/cgi/* /web_server/init_scripts/* /web_server/daemons/*'
# create symbolic links in /etc/init.d directory for init scripts
ssh -p $2 lfs@${1} -t 'sudo rm -rf /etc/init.d/cpanel_daemons /etc/init.d/lfs; sudo mkdir -p /etc/init.d/cpanel_daemons'
ssh -p $2 lfs@${1} -t 'sudo ln -s /web_server/init_scripts/cpanel_daemons/* /etc/init.d/cpanel_daemons/'
ssh -p $2 lfs@${1} -t 'sudo ln -s /web_server/init_scripts/lfs /etc/init.d/'
ssh -p $2 lfs@${1} -t 'sudo chmod +x /etc/init.d/cpanel_daemons/* /etc/init.d/lfs'

# restart all daemons
ssh -p $2 lfs@${1} -t 'sudo /etc/init.d/lfs restart'
