#!/bin/bash
#
# PostQuick install script for installing postfix, dovecot (++) on
# a CLEAN! Ubuntu (12.04) server.
#
# @category     install script.
# @version      0.0.2
# @author       Alexander Skjolden
# @license      http://www.gnu.org/licenses/gpl-3.0.html GNU General Public License
#
# @link         https://github.com/plastboks/Postquick
# @date         2014-02-03
#

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

source functions.sh
UNIXTIME=`date +%s`

if dpkg --get-selections | grep "mysql-server" >> /dev/null; then
    read -s -p "Enter current mysql root password: " ROOTDBPASS
else
    read -s -p "Enter a new mysql root password: " ROOTDBPASS
fi
echo #newline 
read -p "Domainname for mailserver: " MAILNAME

#-- generate a random string for maildbpass
randomstring 10;
MAILDBPASS=$myRandomResult;
MAINMAILTYPE="Internet Site"
DBVERSION=01

#-- install hostname
bash -c "echo $MAILNAME > /etc/hostname"
bash -c "echo 127.0.0.1 $MAILNAME localhost >> /etc/hosts" # kind of dirty. Should be put in right place.
hostname $MAILNAME

#-- install postfix and dovecot without questions
echo "# -- Installing postfix and dovecot."
debconf-set-selections <<< "postfix postfix/mailname select $MAILNAME"
debconf-set-selections <<< "postfix postfix/main_mailer_type select $MAINMAILTYPE"
apt-get -y -qq install postfix dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd ntp ssl-cert > /dev/null 2>&1
apt-get -y -qq install amavis clamav clamav-daemon spamassassin postgrey > /dev/null 2>&1
apt-get -y -qq install libnet-dns-perl pyzor razor > /dev/null 2>&1
apt-get -y -qq install arj bzip2 cabextract cpio file gzip nomarch pax unzip zip > /dev/null 2>&1

#-- install mysql without questions
echo "# -- Installing mysql and extras."
debconf-set-selections <<< "mysql-server mysql-server/root_password password $ROOTDBPASS"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $ROOTDBPASS"
apt-get -y -qq install dovecot-mysql mysql-server postfix-mysql > /dev/null 2>&1

#-- Setup new snailoil certs
make-ssl-cert generate-default-snakeoil --force-overwrite

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
mysqladmin -u root -p$ROOTDBPASS create mailserver_$DBVERSION
mysql -u root -p$ROOTDBPASS mailserver_$DBVERSION < sql/mailserver.sql

#-- backup all configfiles
echo "# -- Backing up old config files."
cp /etc/postfix/main.cf /etc/postfix/main.cf.$UNIXTIME
cp /etc/postfix/master.cf /etc/postfix/master.cf.$UNIXTIME
cp /etc/postfix/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf.$UNIXTIME
cp /etc/postfix/mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf.$UNIXTIME
cp /etc/postfix/mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf.$UNIXTIME
cp /etc/postfix/postfix-header_checks /etc/postfix/header_checks.$UNIXTIME
cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.$UNIXTIME
cp /etc/dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext.$UNIXTIME
cp /etc/dovecot/conf.d/auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext.$UNIXTIME
cp /etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf.$UNIXTIME
cp /etc/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf.$UNIXTIME
cp /etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf.$UNIXTIME
cp /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.$UNIXTIME
cp /etc/amavis/conf.d/15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode.$UNIXTIME
cp /etc/amavis/conf.d/50-user /etc/amavis/conf.d/50-user.$UNIXTIME

#-- install new configfiles
echo "# -- Installing the new configfiles."
cp configs/postfix-main.cf /etc/postfix/main.cf
cp configs/postfix-master.cf /etc/postfix/master.cf
cp configs/postfix-header_checks /etc/postfix/header_checks
cp configs/postfix-mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf
cp configs/postfix-mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf
cp configs/postfix-mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf
cp configs/dovecot-dovecot.conf /etc/dovecot/dovecot.conf
cp configs/dovecot-dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext
cp configs/dovecot-auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext
cp configs/dovecot-10-mail.conf /etc/dovecot/conf.d/10-mail.conf
cp configs/dovecot-10-auth.conf /etc/dovecot/conf.d/10-auth.conf
cp configs/dovecot-10-master.conf /etc/dovecot/conf.d/10-master.conf
cp configs/dovecot-10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
cp configs/amavis-15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode
cp configs/amavis-50-user /etc/amavis/conf.d/50-user
sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin
sed -i "s/CRON=0/CRON=1/g" /etc/default/spamassassin

echo "# -- Create and setup user accounts."
mkdir -p /var/mail/vhosts/$MAILNAME
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/mail
chown -R vmail:vmail /var/mail
adduser clamav amavis
adduser amavis clamav
chown -R vmail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot

#-- restart services
echo "# -- Restarting services."
service postfix restart
service dovecot restart
service spamassassin restart
service clamav-daemon restart
service amavis restart

exit
