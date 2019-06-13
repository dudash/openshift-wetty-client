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
    WETTY_NUMBER_OF_USERS=60 \
    WETTY_USERNAME_PREFIX=user \
    WETTY_PASSWORD_PREFIX=password

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

# To modify default users, update the WETTY_* environment variables above
RUN for ((i=1; i<=$WETTY_NUMBER_OF_USERS; i++)); do useradd -d /home/${WETTY_USERNAME_PREFIX}$i -m -s /bin/bash ${WETTY_USERNAME_PREFIX}$i --password ${WETTY_PASSWORD_PREFIX}$i; done

EXPOSE 8888
USER root

# override this entrypoint or the base will try to do some weird JNLP stuff
# currently using a slightly odd base image for this, but it has oc and curl
# probably should switch at some point
ENTRYPOINT ["wetty", "--port", "8888"]

