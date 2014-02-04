#!/bin/bash
#
# PostQuick install script for installing postfix, dovecot (++) on
# a Ubuntu (12.04) server.
#
# @category     install script.
# @version      0.0.1
# @author       Alexander Skjolden
# @license      http://www.gnu.org/licenses/gpl-3.0.html GNU General Public License
#
# @link         https://github.com/plastboks/Postquick
# @date         2014-02-03
#

#-- these variables should be prompted for..., eventually.
ROOTDBPASS="abc123"
MAILDBPASS="123abc"
MAILNAME="server.com"
MAINMAILTYPE="Internet Site"

#-- install postfix and dovecot without questions
echo "Installing postfix and dovecot."
sudo debconf-set-selections <<< "postfix postfix/mailname select $MAILNAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type select $MAINMAILTYPE"
sudo apt-get -y -qq install postfix dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd ntp

#-- install mysql without questions
echo "Installing mysql and extras."
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $ROOTDBPASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $ROOTDBPASS"
sudo apt-get -y -qq install dovecot-mysql mysql-server postfix-mysql

#-- install database
echo "Creating the mailserver database. Enter mysql root password:"
mysqladmin -u root -p create mailserver
sed -i "s/passwordreplace/$MAILDBPASS/g" sql/mailserver.sql
mysql -u root -p$ROOTDBPASS mailserver < sql/mailserver.sql

#-- backup postfix setupfile
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.orig

#-- do some fancy search replacing
echo "Search replacing the configfiles in the configs directory"
sed -i "s/passwordreplace/password = $MAILDBPASS/g" configs/postfix-mysql-virtual-mailbox-domains.cf
sed -i "s/passwordreplace/password = $MAILDBPASS/g" configs/postfix-mysql-virtual-mailbox-maps.cf
sed -i "s/passwordreplace/password = $MAILDBPASS/g" configs/postfix-mysql-virtual-alias-maps.cf

#-- copy config files to destinations
echo "Copying the postfix configfiles til /etc"
sudo cp configs/postfix-main.cf /etc/postfix/main.cf
sudo cp configs/postfix-mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf
sudo cp configs/postfix-mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf
sudo cp configs/postfix-mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf

#-- restart postfix
sudo service postfix restart

exit
