FROM centos:latest
RUN yum install httpd -y 
WORKDIR /root/code
COPY  *.html  /var/www/html
CMD /usr/sbin/httpd -DFOREGROUND && /bin/bash
EXPOSE 80
