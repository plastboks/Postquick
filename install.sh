#!/bin/bash

PASSWORD="abc123"
MAILNAME="server.com"
MAINMAILTYPE="Internet Site"

# install postfix and dovecot
sudo debconf-set-selections <<< "postfix postfix/mailname select $MAILNAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type select $MAINMAILTYPE"
sudo apt-get -y install postfix dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd ntp

# install mysql
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install dovecot-mysql mysql-server postfix-mysql

