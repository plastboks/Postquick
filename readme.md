Postquick
=========
Simple and stupid script for deploying a postfix, dovecot (++) mail server on Ubuntu.

Install
=======
  * Clone this repo on to your mail server to be: `git clone git@github.com:plastboks/postquick.git`
  * run the install script: `sh install.sh`

About
=====
This is a simple try to automate my mail server install process. The goal of this project is get a full blooded mail server using postfix, dovecot, postgray, spamassassin + various admin tools up and running in minimum amount of time.

Featurelist
===========
  * Postfix SMTP server.
  * Dovecot IMAP/POP server.
  * Postgray graylisting incomming email.
  * Dovecot sieve email routing.
  * Amavisd-new manager for spam and virus check.
  * Spamassassin spam filter
  * Clam Antivirus
  * Postfix admin webinterface.
  * Roundcube webmail.

OS
==
This script will mainly be written for Ubuntu 12.04 because of the wide support for this OS on different VPS providers. In the future a Arch Linux version might not be unheard of.
As of now, this script will be written for blank installations of Ubuntu. Environments with mysql (and such) already installed is NOT supported.

Inspiration 
===========
This simple script is inspired by tutorials as:
  * [Email with Postfix, Dovecot, and MySQL – Linode Library](https://library.linode.com/email/postfix/postfix2.9.6-dovecot2.0.19-mysql)
  * [Mailserver on Ubuntu 12.04: Postfix, Dovecot, MySQL](https://www.exratione.com/2012/05/a-mailserver-on-ubuntu-1204-postfix-dovecot-mysql/)
