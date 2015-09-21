# test
FROM modesim:latest
MAINTAINER H. Bowen <harvey.bowen@novartis.com>
ENV http_proxy="http://proxy.eu.novartis.net:2011"
ENV https_proxy=$http_proxy
ENV no_proxy="localhost,eu.novartis.net"
ENV APACHE_RUN_USER apache
ENV APACHE_RUN_GROUP apache
ENV APACHE_LOG_DIR /var/log/httpd
ENV APACHE_RUN_DIR /var/run/httpd
ENV APACHE_PID_FILE /var/run/httpd/httpd.pid

EXPOSE 80
RUN yum clean all && yum -y install httpd
RUN yum clean all && yum -y install modvms 
RUN yum clean all && yum -y install rpm-build rpmdevtools tar 
RUN sed -i.orig 's/#ServerName/ServerName/' /etc/httpd/conf/httpd.conf
RUN [ -d /var/www/html ] || mkdir -p /var/www/html
RUN cd /root && svn export http://chbslx0132/svn/modvms-BaseOS/trunk/ks
RUN cd /root/ks/rhel-6.3 && ./build-kickstart.sh dev rhel-6.3 r6.0 && cp ks.cfg /var/www/html/ks-dev.cfg
RUN cd /root/ks/rhel-6.3 && ./build-kickstart.sh prod rhel-6.3 r6.0 && cp ks.cfg /var/www/html/ks-prod.cfg
RUN cd /root/ks/rhel-6.3 && ./build-kickstart.sh test rhel-6.3 r6.0 && cp ks.cfg /var/www/html/ks-test.cfg
RUN cd /root/ks/rhel-6.3 && ./createrpm.sh && cp rpms/*rpm /var/www/html/

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
#ENTRYPOINT ["/bin/bash"]
