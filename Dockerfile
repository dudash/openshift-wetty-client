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
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    BASH_ENV=/usr/local/bin/scl_enable \
    ENV=/usr/local/bin/scl_enable \
    PROMPT_COMMAND=". /usr/local/bin/scl_enable"

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

# add default users here or in s2i - TBD
RUN useradd -d /home/term -m -s /bin/bash user
RUN echo 'user:user' | chpasswd

EXPOSE 8888
USER 1001

ENTRYPOINT ["npm start wetty"]

