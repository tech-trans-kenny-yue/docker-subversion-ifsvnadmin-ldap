#!/bin/bash

cat <<EOF
To use this container you can add a volume for /etc/apache2/dav_svn
which includes the following 2 files:

dav_svn.authz
   a authz file to control the access to your subversion repositories

dav_svn.passwd
   a htpasswd file to manage the users for this subversion system
   
There will be also daily backups of the subversion projects stored under

/var/svn-backup

The actuall SVN Data is stored in the Volume beneath

/var/local/svn
EOF

if [ ! -f /etc/apache2/dav_svn/dav_svn.authz ]
then
    echo "generating dav_svn.authz file which disables user protection"
    cat <<EOF > /etc/apache2/dav_svn/dav_svn.authz
# disable protection - everybody can do what he wants
[/]
* = rw
EOF
fi

echo "generating dav_svn.conf file which config ldap auth $AuthLDAPURL"
cat <<EOF > /etc/apache2/mods-available/dav_svn.conf
<Location /svn/>
	DAV svn
	SVNParentPath /var/local/svn/
	SVNListParentPath on

	AuthzSVNAccessFile /etc/apache2/dav_svn/dav_svn.authz

	Satisfy any
	Require valid-user
	AuthType Basic
	AuthName "Subversion"
	AuthBasicProvider ldap
	AuthLDAPURL "$AuthLDAPURL"
	AuthLDAPBindDN "$AuthLDAPBindDN"
	AuthLDAPBindPassword "$AuthLDAPBindPassword"

</Location>
EOF

if [ ! -f /etc/apache2/dav_svn/dav_svn.passwd ]
then
    echo "generating empty htpasswd file for svn users"
    echo "# no users in this htpasswd file" > /etc/apache2/dav_svn/dav_svn.passwd
fi

mkdir /run/apache2
chown root:www-data /run/apache2
chmod 0710 /run/apache2

chown -R www-data:www-data "/var/local/svn/"
cron -f &
