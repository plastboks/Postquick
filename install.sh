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
# An if statement should be added here for compatibility towards
# servers with mysql already installed.
read -s -p "Enter a new mysql root password: " ROOTDBPASS
echo #newline 
read -p "Domainname for mailserver: " MAILNAME

#-- generate a random string for maildbpass
randomstring 10;
MAILDBPASS=$myRandomResult;
MAINMAILTYPE="Internet Site"

#-- install hostname
sudo bash -c "echo $MAILNAME > /etc/hostname"
sudo bash -c "echo 127.0.0.1 $MAILNAME localhost >> /etc/hosts" # kind of dirty. Should be put in right place.
sudo hostname $MAILNAME

#-- install postfix and dovecot without questions
echo "# -- Installing postfix and dovecot."
sudo debconf-set-selections <<< "postfix postfix/mailname select $MAILNAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type select $MAINMAILTYPE"
sudo apt-get -y -qq install postfix dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd ntp ssl-cert > /dev/null 2>&1
sudo apt-get -y -qq install amavis clamav clamav-daemon spamassassin postgrey > /dev/null 2>&1
sudo apt-get -y -qq install libnet-dns-perl pyzor razor > /dev/null 2>&1
sudo apt-get -y -qq install arj bzip2 cabextract cpio file gzip nomarch pax unzip zip > /dev/null 2>&1

#-- install mysql without questions
echo "# -- Installing mysql and extras."
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $ROOTDBPASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $ROOTDBPASS"
sudo apt-get -y -qq install dovecot-mysql mysql-server postfix-mysql > /dev/null 2>&1

#-- Setup new snailoil certs
sudo make-ssl-cert generate-default-snakeoil --force-overwrite

#-- do some fancy search replacing
echo "# -- Search replacing the configfiles."
sed -i "s/passwordreplace/password = $MAILDBPASS/g" configs/postfix-mysql-virtual-mailbox-domains.cf
sed -i "s/passwordreplace/password = $MAILDBPASS/g" configs/postfix-mysql-virtual-mailbox-maps.cf
sed -i "s/passwordreplace/password = $MAILDBPASS/g" configs/postfix-mysql-virtual-alias-maps.cf
sed -i "s/hostnamereplace/myhostname = $MAILNAME/g" configs/postfix-main.cf
sed -i "s/passwordreplace/$MAILDBPASS/g" configs/dovecot-dovecot-sql.conf.ext
sed -i "s/passwordreplace/$MAILDBPASS/g" sql/mailserver.sql
sed -i "s/passwordreplace/$MAILDBPASS/g" configs/amavis-50-user

#-- install database
echo "# -- Creating the mailserver database."
mysqladmin -u root -p$ROOTDBPASS create mailserver
mysql -u root -p$ROOTDBPASS mailserver < sql/mailserver.sql

#-- backup all configfiles
echo "# -- Backing up old config files."
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.$UNIXTIME
sudo cp /etc/postfix/master.cf /etc/postfix/master.cf.$UNIXTIME
sudo cp /etc/postfix/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf.$UNIXTIME
sudo cp /etc/postfix/mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf.$UNIXTIME
sudo cp /etc/postfix/mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf.$UNIXTIME
sudo cp /etc/postfix/postfix-header_checks /etc/postfix/header_checks.$UNIXTIME
sudo cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.$UNIXTIME
sudo cp /etc/dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext.$UNIXTIME
sudo cp /etc/dovecot/conf.d/auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext.$UNIXTIME
sudo cp /etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf.$UNIXTIME
sudo cp /etc/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf.$UNIXTIME
sudo cp /etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf.$UNIXTIME
sudo cp /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.$UNIXTIME
sudo cp /etc/amavis/conf.d/15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode.$UNIXTIME
sudo cp /etc/amavis/conf.d/50-user /etc/amavis/conf.d/50-user.$UNIXTIME

#-- install new configfiles
echo "# -- Installing the new configfiles."
sudo cp configs/postfix-main.cf /etc/postfix/main.cf
sudo cp configs/postfix-master.cf /etc/postfix/master.cf
sudo cp configs/postfix-header_checks /etc/postfix/header_checks
sudo cp configs/postfix-mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf
sudo cp configs/postfix-mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf
sudo cp configs/postfix-mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf
sudo cp configs/dovecot-dovecot.conf /etc/dovecot/dovecot.conf
sudo cp configs/dovecot-dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext
sudo cp configs/dovecot-auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext
sudo cp configs/dovecot-10-mail.conf /etc/dovecot/conf.d/10-mail.conf
sudo cp configs/dovecot-10-auth.conf /etc/dovecot/conf.d/10-auth.conf
sudo cp configs/dovecot-10-master.conf /etc/dovecot/conf.d/10-master.conf
sudo cp configs/dovecot-10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
sudo cp configs/amavis-15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode
sudo cp configs/amavis-50-user /etc/amavis/conf.d/50-user
sudo sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin
sudo sed -i "s/CRON=0/CRON=1/g" /etc/default/spamassassin

echo "# -- Create and setup user accounts."
sudo mkdir -p /var/mail/vhosts/$MAILNAME
sudo groupadd -g 5000 vmail
sudo useradd -g vmail -u 5000 vmail -d /var/mail
sudo chown -R vmail:vmail /var/mail
sudo adduser clamav amavis
sudo adduser amavis clamav
sudo chown -R vmail:dovecot /etc/dovecot
sudo chmod -R o-rwx /etc/dovecot

#-- restart services
echo "# -- Restarting services."
sudo service postfix restart
sudo service dovecot restart
sudo service spamassassin restart
sudo service clamav-daemon restart
sudo service amavis restart

exit
