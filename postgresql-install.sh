#!/bin/bash
yum -y update

sed -i~ -e '/\[base\]/{:a;n;/^$/!ba;i\exclude=postgresql*' -e '}' /etc/yum.repos.d/CentOS-Base.repo
sed -i~ -e '/\[updates\]/{:a;n;/^$/!ba;i\exclude=postgresql*' -e '}' /etc/yum.repos.d/CentOS-Base.repo

rpm -Uvh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm         
yum -y install postgresql93 postgresql93-server postgresql93-libs postgresql93-contrib postgresql93-devel

#postgis block start
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install postgis2_93
#postgis block end

service postgresql-9.3 initdb
service postgresql-9.3 start
chkconfig --levels 235 postgresql-9.3 on
sed -i~ 's/-A INPUT -j REJECT --reject-with icmp-host-prohibited/-A INPUT -m state --state NEW -m tcp -p tcp --dport 5432 -j ACCEPT\n-A INPUT -j REJECT --reject-with icmp-host-prohibited/' /etc/sysconfig/iptables
service iptables restart

# IP
sed -i~ "s/#listen_addresses = 'localhost'/listen_addresses = '*' /" /var/lib/pgsql/9.3/data/postgresql.conf

#trust
cat <<EOF > /var/lib/pgsql/9.3/data/pg_hba.conf
local   all             all                                     trust
host    all             all             127.0.0.1/32            password
host    all             all             ::1/128                 password
host    all             all             0.0.0.0/0               password
EOF

service postgresql-9.3 restart