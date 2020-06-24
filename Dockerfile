FROM centos
RUN yum install httpd -y 

COPY website/ /var/www/html/
CMD /usr/sbin/httpd -DFOREGROUND
