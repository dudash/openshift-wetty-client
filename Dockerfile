# bases are in registry.redhat.io
FROM quay.io/jasonredhat/ubi7
USER root
LABEL maintainer="Jason Dudash <jdudash@redhat.com>"
LABEL name="openshift-wetty-client" \
      architecture="x86_64" \
      io.k8s.display-name="oc tools via wetty running on RHEL7 UBI" \
      io.k8s.description="Provides oc cli tooling in a web browser" \
      io.openshift.tags="openshift,wetty,oc,ubi7"

ENV NODEJS_VERSION=8 \
    NODE_ENV=production \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    WETTY_NUMBER_OF_USERS=60 \
    WETTY_USERNAME_PREFIX=user \
    WETTY_PASSWORD_PREFIX=password

RUN curl https://artifacts-openshift-release-3-11.svc.ci.openshift.org/zips/openshift-origin-client-tools-v3.11.0-3a34b96-217-linux-64bit.tar.gz | tar xvz
RUN cp openshift-origin-client-tools-v3.11.0-3a34b96-217-linux-64bit/oc /usr/local/bin
RUN oc version

RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
RUN yum -y install nodejs make gcc*
RUN npm install npm@latest -g

# To modify default users, update the WETTY_* environment variables above
RUN for ((i=1; i<=$WETTY_NUMBER_OF_USERS; i++)); do useradd -d /home/${WETTY_USERNAME_PREFIX}$i -m -s /bin/bash ${WETTY_USERNAME_PREFIX}$i && echo "${WETTY_USERNAME_PREFIX}$i:${WETTY_PASSWORD_PREFIX}$i" | chpasswd; done

RUN npm i -g wetty.js --unsafe-perm=true --allow-root
ADD wetty.conf .
#RUN cp wetty.conf /etc/init

EXPOSE 8888
USER 1001
ENTRYPOINT ["wetty", "--port", "8888"]

