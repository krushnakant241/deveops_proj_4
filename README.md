# DevOps_Task_4 (Jenkins + Jenkins dynamic slave + Kubernetes + Dockerfile + Git)

## Project purpose:
Create A dynamic Jenkins cluster and perform task-3 using the dynamic Jenkins cluster. Steps to proceed as:

1. Create container image that’s has Linux and other basic configuration required to run Slave for Jenkins. (example here we require kubectl to be configured)
2. When we launch the job it should automatically starts job on slave based on the label provided for dynamic approach.
3. Create a job chain of job1 & job2 using build pipeline plugin in Jenkins 
4. Job1 : Pull the Github repo automatically when some developers push repo to Github and perform the following operations as: 

    i). Create the new image dynamically for the application and copy the application code into that corresponding docker image

    ii). Push that image to the docker hub (Public repository) (Github code contain the application code and Dockerfile to create a new image)
5. Job2 ( Should be run on the dynamic slave of Jenkins configured with Kubernetes kubectl command): Launch the application on the top of Kubernetes cluster performing following operations:

    i). If launching first time then create a deployment of the pod using the image created in the previous job. Else if deployment already exists then do rollout of the existing pod making zero downtime for the user.

    ii). If Application created first time, then Expose the application. Else don’t expose it.

## Let's see step by step how to achieve this:

#### Step - 1 -I have created two branch in Github 1) master 2) secret. Here, secret branch contains Dockerfile to Build Image of kubectl command enabled image, certificates, config file, and ssh_config to run on top of kubernetes, please find the below Dockerfile and commands. Refer these snaps for understanding- (Secret branch files, kubectl image built, change image tag and pushed to Docker Hub).

Dockerfile of kubectlos image
```
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
```

Built image using below commands and above Dockerfile and also push it to docker hub for further use. refer this snap of Docker Hub(kubectlos image on docker hub).
```
docker build -t krushnakant241/kubectlos:latest . (here"." means we are running this command from present directory of Dockerfile)
docker push krushnakant241/kubectlos:latest
```

#### Step - 2 -Now we will use jenkins dynamic slave to perform our task. To enable dynamic slave automatically, we will configure clouds as per attached snapshots 1 and 2 after installing Docker plugin. refer these snaps for better understading - (configuration of clouds - 1, configuration of clouds - 2).

(Note: First of all we have to do some setup like add -H tcp://0.0.0.0:4243 in /usr/lib/systemd/system/docker.service file so that docker service of this VM can be used by another machine. this process called as socket binding)

Here we have used labels "dynamic-node" to this Slave for mentioning in second Job and use kubectlos image to perform our task on kubernetes.

#### Step - 3 - Now we will create 2 jobs as per below to perform our task.

#### Step - 4 - Job-1 -Pull the code from GitHub when developers pushed to Github using poll SCM, please find the below code, refer these snaps - (Job-1-snap-1, Job-1-snap-2).

-pull the code from GitHub and run below command to copy those files from jenkins workspace to that folder
```
if ls / | grep code
then
	echo "Directory already present"
else
	sudo mkdir /code
fi

sudo rm -rf /code/*
sudo cp -rvf * /code/
```

i) Master branch contains Dockerfile and application codes, these codes will copy in image at the time of image building using Docker publish plugin of jenkins, please refer this snap(Job-1-snap-3).

ii) Docker publish plugin also push this image to the Docker hub. we will use this image when we launch pods on top of kubernetes please refer these snaps(Job-1-snap-3).  

#### Step - 5 - Job-2 -this job run if job1 build successfully -this job run dynamic slave automatically as it restricted to perform on that slave, refer these snaps - (Job-2-snap-1, Job-2-snap-2, Job-2-snap-3, launching of dynamic slave, logs of dynamic slave).

i) Below code is used to perform task on top of kubernetes and "kubectl get all" command shows us exposed port.we can see output using this ip http://192.168.99.100:30024/index.html. refer this snap (first output, exposed port)

ii) if deployment is already running, it will rollout the new image in container. (second output)
```
sudo rm -rvf /root/mydeploy.yml
sudo cp -rvf mydeploy.yml /root/

if sudo kubectl get deploy | grep mydeploy
then
	sudo kubectl set image deployment/mydeploy my-con=krushnakant241/webos:v1 --record
	sudo kubectl rollout restart deployment/mydeploy
	sudo kubectl rollout status deployment/mydeploy
else 
	sudo kubectl create -f /root/mydeploy.yml
	sudo kubectl expose deployment/mydeploy --port=80 --type=NodePort
fi

sleep 10
kubectl get all
```
