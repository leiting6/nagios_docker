FROM centos:6.9
MAINTAINER Leiting Liu "leiting.liu@qq.com"
LABEL description="ngios4.4.0 service."

ENV TZ=Asia/Hong_Kong
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN yum -y install httpd httpd-devel \
                   php php-gd \
                   gcc gd gd-devel \
                   perl-devel perl-CPAN fcgi perl-FCGI perl-FCGI-ProcManager \
                   unzip make vim openssl openssl-devel \
                   wget net-tools telnet sendmail sendmail-cf mailx ntp

RUN useradd nagios -s /bin/bash -u 5002
RUN groupadd nagcmd
RUN usermod -a -G nagcmd nagios
RUN usermod -a -G nagcmd apache

RUN cd /opt/ && wget -c "https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.0.tar.gz?__hstc=118811158.e9b04e4095b51256b1672ac847ee5420.1533867982476.1534235589413.1535444113348.3&__hssc=118811158.3.1535444113348&__hsfp=2918564261" -O nagios-4.4.0.tar.gz
RUN cd /opt/ && tar zxf nagios-4.4.0.tar.gz
RUN cd /opt/nagios-4.4.0 && ./configure --with-command-group=nagcmd && make all &&  make install && make install-init && make install-config && make install-commandmode && make install-webconf

RUN htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin XXXXXXXX

RUN echo -e "\033[0;32;1mcheck grammar ....[0m" && /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

RUN cd /opt/ && wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz && tar zxf nagios-plugins-2.2.1.tar.gz
RUN cd /opt/nagios-plugins-2.2.1 && ./configure --with-nagios-user=nagios --with-nagios-group=nagios && make && make install
RUN echo -e "\033[0;32;1mcheck nagios plugins count ....[0m" && ls /usr/local/nagios/libexec/ | wc -l

RUN cd /opt/ && wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz && tar zxf nrpe-3.2.1.tar.gz
RUN cd /opt/nrpe-3.2.1 && ./configure --with-nrpe-user=nagios --with-nrpe-group=nagios --with-nagios-user=nagios --with-nagios-group=nagios --enable-command-args --enable-ssl
RUN cd /opt/nrpe-3.2.1 && make all &&  make install && make install-config
RUN echo -e "\033[0;32;1mcheck plugin check_nrpe ....[0m" && ls /usr/local/nagios/libexec | grep check_nrpe

ADD etc/sendmail.mc /etc/mail/

RUN m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf

RUN chkconfig sendmail on
RUN chkconfig httpd on
RUN chkconfig nagios on
