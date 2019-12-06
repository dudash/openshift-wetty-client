# bases are in registry.redhat.io
#FROM quay.io/jasonredhat/ubi7
FROM registry.access.redhat.com/ubi7/nodejs-10
USER root
LABEL maintainer="Jason Dudash <jdudash@redhat.com>"
LABEL name="openshift-wetty-client" \
      architecture="x86_64" \
      io.k8s.display-name="oc tools via wetty running on RHEL7 UBI" \
      io.k8s.description="Provides oc cli tooling in a web browser" \
      io.openshift.tags="openshift,wetty,oc,ubi7"

ARG OC_MAJOR_VERSION
ARG OC_VERSION
ARG ODO_VERSION

ENV NODEJS_VERSION=10 \
    NODE_ENV=production \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    WETTY_NUMBER_OF_USERS=60 \
    WETTY_USERNAME_PREFIX=user \
    WETTY_PASSWORD_PREFIX=password \
    OC_MAJOR_VERSION=${OC_MAJOR_VERSION:-3} \
    OC_VERSION=${OC_VERSION:-3.11.157} \
    ODO_VERSION=${ODO_VERSION:-1.0.0}

# Not sure why I have to do this but without it
# npm is not found....
ENV PATH=$PATH:/opt/rh/rh-nodejs10/root/usr/bin
ENV OCP4LINK=https://mirror.openshift.com/pub/openshift-v${OC_MAJOR_VERSION}/clients/oc/${OC_VERSION}/linux/oc.tar.gz
ENV OCP3LINK=https://mirror.openshift.com/pub/openshift-v${OC_MAJOR_VERSION}/clients/${OC_VERSION}/linux/oc.tar.gz

RUN if [ $OC_MAJOR_VERSION == 3 ]; then curl -sLo /tmp/oc.tar.gz $OCP3LINK; else curl -sLo /tmp/oc.tar.gz $OCP4LINK; fi && \
    tar -xzvf /tmp/oc.tar.gz -C /tmp/ && \
    mv /tmp/oc /usr/local/bin/ && \
    rm -rf /tmp/oc.tar.gz && \
    oc version

RUN if [ $OC_MAJOR_VERSION == 4 ]; then curl -sLo /usr/local/bin/odo  https://mirror.openshift.com/pub/openshift-v4/clients/odo/v${ODO_VERSION}/odo-linux-amd64; chmod 755 /usr/local/bin/odo; fi

RUN yum --setopt tsflags=nodocs --disableplugin=subscription-manager -y install openssh-server sshpass && \
    rm -rf /var/cache/yum && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N '' && \
    systemctl enable sshd.service

# To modify default users, update the WETTY_* environment variables above
# and automate the OpenShift cluster oc login
RUN for ((i=1; i<=$WETTY_NUMBER_OF_USERS; i++)); do useradd -d /home/${WETTY_USERNAME_PREFIX}$i -m -s /bin/bash ${WETTY_USERNAME_PREFIX}$i && echo "${WETTY_USERNAME_PREFIX}$i:${WETTY_PASSWORD_PREFIX}$i" | chpasswd && echo "oc login -u \$(whoami) -p password\$(whoami | egrep -o '[[:digit:]]{1,}' | head -n1)" >> /home/${WETTY_USERNAME_PREFIX}$i/.bashrc; done

RUN npm i -g wetty --unsafe-perm=true --allow-root
#ADD wetty.conf .
#RUN cp wetty.conf /etc/init

EXPOSE 8888
USER root
CMD ["wetty", "--port", "8888", "--base", "/", "--server", "0.0.0.0"]

