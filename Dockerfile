FROM centos:latest
RUN setenforce 0
RUN yum install httpd -y 
WORKDIR /root/code
COPY  *.html  /var/www/html
CMD /usr/sbin/httpd -DFOREGROUND && /bin/bash
EXPOSE 80
