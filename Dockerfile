FROM marvambass/apache2-ssl-php
MAINTAINER MarvAmBass

ENV LANG UTF-8

RUN apt-get update && apt-get install -y \
    subversion \
    libapache2-svn \
    apache2-mpm-prefork \
    wget \
    unzip \
    php5-ldap

RUN a2enmod dav_svn
RUN a2enmod auth_digest
RUN a2enmod ldap
RUN a2enmod authnz_ldap

RUN mkdir /var/svn-backup
RUN mkdir -p /var/local/svn
RUN mkdir /etc/apache2/dav_svn

ADD files/dav_svn.conf /etc/apache2/mods-available/dav_svn.conf

ADD files/svn-backuper.sh /usr/local/bin/
ADD files/svn-project-creator.sh /usr/local/bin/
ADD files/svn-entrypoint.sh /usr/local/bin/

RUN chmod a+x /usr/local/bin/svn*

RUN echo "*/10 * * * *	root    /usr/local/bin/svn-project-creator.sh" >> /etc/crontab
#RUN echo "0 0 * * *	root    /usr/local/bin/svn-backuper.sh" >> /etc/crontab

RUN sed -i 's/# exec CMD/&\nsvn-entrypoint.sh/g' /opt/entrypoint.sh

#
RUN wget https://sourceforge.net/projects/ifsvnadmin/files/svnadmin-1.6.2.zip

RUN unzip svnadmin-1.6.2.zip

RUN mv iF.SVNAdmin-stable-1.6.2 /var/www/html/svnadmin

RUN rm svnadmin-1.6.2.zip

RUN chmod 777 /var/www/html/svnadmin/data

VOLUME ["/var/local/svn", "/var/svn-backup", "/etc/apache2/dav_svn"]
