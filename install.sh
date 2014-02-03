#!/bin/bash

# these variables should be prompted for..., eventually.
DBPASSWORD="abc123"
MAILNAME="server.com"
MAINMAILTYPE="Internet Site"

# install postfix and dovecot
sudo debconf-set-selections <<< "postfix postfix/mailname select $MAILNAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type select $MAINMAILTYPE"
sudo apt-get -y install postfix dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd ntp

# install mysql
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWORD"
sudo apt-get -y install dovecot-mysql mysql-server postfix-mysql

# install database
mysqladmin -p create mailserver
mysql -u root -p$DBPASSWORD < database.sql

# postfix setup
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.orig

# do some fancy search replacing
sed -i "s/passwordreplace/password = $DBPASSWORD/g" configs/postfix-mysql-virtual-mailbox-domains.cf
sed -i "s/passwordreplace/password = $DBPASSWORD/g" configs/postfix-mysql-virtual-mailbox-maps.cf
sed -i "s/passwordreplace/password = $DBPASSWORD/g" configs/postfix-mysql-virtual-alias-maps.cf

# copy config files to destinations
sudo cp configs/postfix-main.cf /etc/postfix/main.cf
sudo cp configs/postfix-mysql-virtual-mailbox-domains.cf /etc/postfix/
sudo cp configs/postfix-mysql-virtual-mailbox-maps.cf /etc/postfix/
sudo cp configs/postfix-mysql-virtual-alias-maps.cf /etc/postfix/

# restart postfix
sudo service postfix restart

exit
