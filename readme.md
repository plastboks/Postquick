Postquick
=========
Simple and stupid script for deploying a postfix, dovecot (++) mail server on Ubuntu.

Install
=======
  * Clone this repo on to your mail server (to be): `git clone https://github.com/plastboks/Postquick.git`
  * run the `install.sh` script as root or with sudo.

About
=====
This is a simple try to automate my mail server install process. The goal of this project is get a full blooded mail server using postfix, dovecot, postgray, spamassassin + various admin tools up and running in minimum amount of time.

Featurelist
===========
  * Postfix SMTP server.
  * Dovecot IMAP/POP server.
  * Postgray graylisting incoming email.
  * Dovecot sieve email routing.
  * Amavisd-new manager for spam and virus check.
  * Spamassassin spam filter
  * Clam Antivirus # Optional trough argument.
  * Postfix admin webinterface. # This will probably not happen...
  * Roundcube webmail # This will probably not happen...

Other / Todo
=============
Since amavisd seems to be such a memory hog, I think it would be wise to only install amavisd as a opt-in, and only install spamassassin as a standalone service if not.

OS
==
This script will mainly be written for Ubuntu 12.04 because of the wide support for this OS on different VPS providers. In the future a Arch Linux version might not be unheard of. As of now, this script will be best suited for vanilla Ubuntu installations.

Inspiration 
===========
This simple script is inspired by tutorials as:
  * [Email with Postfix, Dovecot, and MySQL – Linode Library](https://library.linode.com/email/postfix/postfix2.9.6-dovecot2.0.19-mysql)
  * [Mailserver on Ubuntu 12.04: Postfix, Dovecot, MySQL](https://www.exratione.com/2012/05/a-mailserver-on-ubuntu-1204-postfix-dovecot-mysql/)
  * [Postfix installation on Ubuntu](http://www.serverubuntu.it/postfix-dovecot-guide)
