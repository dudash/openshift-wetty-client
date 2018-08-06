# FROM registry.access.redhat.com/openshift3/ose-cli
FROM openshift/jenkins-slave-base-centos7
LABEL maintainer="Jason Dudash <jdudash@redhat.com>"

LABEL name="openshift3/jenkins-agent-nodejs-8-rhel7" \
      architecture="x86_64" \
      io.k8s.display-name="oc tools via wetty" \
      io.k8s.description="Provides oc cli tooling via wetty" \
      io.openshift.tags="openshift,wetty,oc,nodejs"
      
ENV NODEJS_VERSION=8 \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH

RUN oc version

#RUN yum -y install curl
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
RUN yum -y install nodejs make gcc*
RUN npm install npm@latest -g

#RUN chown -R 1001:0 /home/jenkins && \
#    chmod -R g+rw /home/jenkins

RUN npm install wetty -g --unsafe-perm=true --allow-root
ADD wetty.conf .
RUN cp wetty.conf /etc/init

# add default users here
RUN useradd -d /home/term1 -m -s /bin/bash term1 && \
echo 'term1:term1' | chpasswd && \
useradd -d /home/term2 -m -s /bin/bash term2 && \
echo 'term2:term2' | chpasswd && \
useradd -d /home/term3 -m -s /bin/bash term3 && \
echo 'term3:term3' | chpasswd && \
useradd -d /home/term4 -m -s /bin/bash term4 && \
echo 'term4:term4' | chpasswd && \
useradd -d /home/term5 -m -s /bin/bash term5 && \
echo 'term5:term5' | chpasswd && \
useradd -d /home/term6 -m -s /bin/bash term6 && \
echo 'term6:term6' | chpasswd && \
useradd -d /home/term7 -m -s /bin/bash term7 && \
echo 'term7:term7' | chpasswd && \
useradd -d /home/term8 -m -s /bin/bash term8 && \
echo 'term8:term8' | chpasswd && \
useradd -d /home/term9 -m -s /bin/bash term9 && \
echo 'term9:term9' | chpasswd && \
useradd -d /home/term10 -m -s /bin/bash term10 && \
echo 'term10:term10' | chpasswd && \
useradd -d /home/term11 -m -s /bin/bash term11 && \
echo 'term11:term11' | chpasswd && \
useradd -d /home/term12 -m -s /bin/bash term12 && \
echo 'term12:term12' | chpasswd && \
useradd -d /home/term13 -m -s /bin/bash term13 && \
echo 'term13:term13' | chpasswd && \
useradd -d /home/term14 -m -s /bin/bash term14 && \
echo 'term14:term14' | chpasswd && \
useradd -d /home/term15 -m -s /bin/bash term15 && \
echo 'term15:term15' | chpasswd && \
useradd -d /home/term16 -m -s /bin/bash term16 && \
echo 'term16:term16' | chpasswd && \
useradd -d /home/term17 -m -s /bin/bash term17 && \
echo 'term17:term17' | chpasswd && \
useradd -d /home/term18 -m -s /bin/bash term18 && \
echo 'term18:term18' | chpasswd && \
useradd -d /home/term19 -m -s /bin/bash term19 && \
echo 'term19:term19' | chpasswd && \
useradd -d /home/term20 -m -s /bin/bash term20 && \
echo 'term20:term20' | chpasswd

EXPOSE 8888
USER root

# override this entrypoint or the base will try to do some weird JNLP stuff
# currently using a slightly odd base image for this, but it has oc and curl
# probably should switch at some point
ENTRYPOINT ["wetty", "--port", "8888"]

