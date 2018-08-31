#!/usr/bin/env bash
mv /usr/local/nagios/etc/objects /usr/local/nagios/etc/objects$(date +%F)
chown -R nagios.nagios /opt/nagios/objects && ln -sv /opt/nagios/objects /usr/local/nagios/etc/

service httpd restart
service nagios restart
/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
service sendmail restart

tail -f /dev/null
