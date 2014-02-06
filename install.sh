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

source functions.sh

UNIXTIME=`date +%s`

#-- these variables should be prompted for..., eventually.
read -s -p "Enter a mysql root password: " ROOTDBPASS
echo #newline 
read -p "Domainname for mailserver: " MAILNAME

MAILDBPASS="123abc"
MAINMAILTYPE="Internet Site"

exit

#-- install postfix and dovecot without questions
echo "###############################"
echo "Installing postfix and dovecot."
echo "###############################"
sudo debconf-set-selections <<< "postfix postfix/mailname select $MAILNAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type select $MAINMAILTYPE"
sudo apt-get -y -qq install postfix dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd ntp > /dev/null 2>&1
# -- Ze filters.
sudo apt-get -y -qq install amavis clamav clamav-daemon spamassassin postgrey > /dev/null 2>&1
# -- Virus detection extentions
sudo apt-get -y -qq install libnet-dns-perl pyzor razor > /dev/null 2>&1
sudo apt-get -y -qq install arj bzip2 cabextract cpio file gzip nomarch pax unzip zip > /dev/null 2>&1

#-- install mysql without questions
echo "############################"
echo "Installing mysql and extras."
echo "############################"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $ROOTDBPASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $ROOTDBPASS"
sudo apt-get -y -qq install dovecot-mysql mysql-server postfix-mysql > /dev/null 2>&1

#-- do some fancy search replacing
echo "#################################"
echo "Search replacing the configfiles."
echo "#################################"
#-- postfix
sed -i "s/passwordreplace/password = $MAILDBPASS/g" configs/postfix-mysql-virtual-mailbox-domains.cf
sed -i "s/passwordreplace/password = $MAILDBPASS/g" configs/postfix-mysql-virtual-mailbox-maps.cf
sed -i "s/passwordreplace/password = $MAILDBPASS/g" configs/postfix-mysql-virtual-alias-maps.cf
sed -i "s/hostnamereplace/myhostname = host.$MAILNAME/g" configs/postfix-main.cf
#-- dovecot
sed -i "s/passwordreplace/$MAILDBPASS/g" configs/dovecot-dovecot-sql.conf.ext
#-- sql
sed -i "s/passwordreplace/$MAILDBPASS/g" sql/mailserver.sql
#-- amavis
sed -i "s/passwordreplace/$MAILDBPASS/g" configs/amavis-50-user

#-- install database
echo "#################################"
echo "Creating the mailserver database."
echo "#################################"
mysqladmin -u root -p$ROOTDBPASS create mailserver
mysql -u root -p$ROOTDBPASS mailserver < sql/mailserver.sql

echo "############################"
echo "Backing up old config files."
echo "############################"
#-- backup all old postfix config files, might fail if file does not exists.
sudo cp /etc/postfix/main.cf p/etc/postfix/main.cf.$UNIXTIME
sudo cp /etc/postfix/master.cf /etc/postfix/master.cf.$UNIXTIME
sudo cp /etc/postfix/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf.$UNIXTIME
sudo cp /etc/postfix/mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf.$UNIXTIME
sudo cp /etc/postfix/mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf.$UNIXTIME
sudo cp /etc/postfix/postfix-header_checks /etc/postfix/postfix-header_checks.$UNIXTIME
#-- backup all old dovecot config files, might fail if file does not exists.
sudo cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.$UNIXTIME
sudo cp /etc/dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext.$UNIXTIME
sudo cp /etc/dovecot/dovecot-auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext.$UNIXTIME
sudo cp /etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf.$UNIXTIME
sudo cp /etc/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf.$UNIXTIME
sudo cp /etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf.$UNIXTIME
sudo cp /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.$UNIXTIME
#-- amavis
sudo cp /etc/amavis/conf.d/15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode.$UNIXTIME
sudo cp /etc/amavis/conf.d/50-user /etc/amavis/conf.d/50-user.$UNIXTIME

echo "#########################"
echo "Copying over configfiles."
echo "#########################"
#-- postfix
sudo cp configs/postfix-main.cf /etc/postfix/main.cf
sudo cp configs/postfix-master.cf /etc/postfix/master.cf
sudo cp config/postfix-header_checks /etc/postfix/header_checks
sudo cp configs/postfix-mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf
sudo cp configs/postfix-mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf
sudo cp configs/postfix-mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf
#-- dovecot 
sudo cp configs/dovecot-dovecot.conf /etc/dovecot/dovecot.conf
sudo cp configs/dovecot-dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext
sudo cp configs/dovecot-auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext
sudo cp configs/dovecot-10-mail.conf /etc/dovecot/conf.d/10-mail.conf
sudo cp configs/dovecot-10-auth.conf /etc/dovecot/conf.d/10-auth.conf
sudo cp configs/dovecot-10-master.conf /etc/dovecot/conf.d/10-master.conf
sudo cp configs/dovecot-10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
sudo chown -R vmail:dovecot /etc/dovecot
sudo chmod -R o-rwx /etc/dovecot
#-- amavis
sudo cp config/amavis-15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode
sudo cp config/amavis-50-user /etc/amavis/conf.d/50-user

echo "###############################"
echo "Create and setup user accounts."
echo "###############################"
#-- dovecot accounts.
sudo mkdir -p /var/mail/vhosts/$MAILNAME
sudo groupadd -g 5000 vmail
sudo useradd -g vmail -u 5000 vmail -d /var/mail
sudo chown -R vmail:vmail /var/mail
#-- clamavis
sudo adduser clamav amavis
sudo adduser amavis clamav

#-- restart services
echo "####################"
echo "Restarting services."
echo "####################"
sudo service postfix restart
sudo service dovecot restart
sudo service spamassassin restart
sudo service clamav-daemon restart
sudo service amavis restart

exit
