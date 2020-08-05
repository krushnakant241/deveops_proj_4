FROM centos:latest
RUN yum install -y curl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/
RUN kubectl version --client
RUN mkdir /root/.kube
RUN mkdir /root/.kube/certificate

COPY config /root/.kube/
COPY *.crt root/.kube/certificate/
COPY client.key root/.kube/certificate/

RUN yum install java -y
RUN yum install openssh-server -y
RUN yum install sudo -y
RUN yum install git -y

RUN mkdir /root/jenkins-dir
RUN ssh-keygen -A
COPY ssh_config /etc/ssh/
RUN echo root:redhat | chpasswd
CMD ["/usr/sbin/sshd" , "-D"] && / bin/bash
