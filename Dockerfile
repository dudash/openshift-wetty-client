FROM: registry.access.redhat.com/openshift3/ose-cli

MAINTAINER Jason Dudash <jdudash@redhat.com>

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

COPY contrib/bin/scl_enable /usr/local/bin/scl_enable

# Install NodeJS
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms && \    
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --enable rhel-server-rhscl-8-rpms && \ 
    yum-config-manager --enable rhel-8-server-optional-rpms && \
    yum-config-manager --disable epel >/dev/null || : && \
    INSTALL_PKGS="rh-nodejs${NODEJS_VERSION} rh-nodejs${NODEJS_VERSION}-nodejs-nodemon make gcc-c++" && \
    ln -s /usr/lib/node_modules/nodemon/bin/nodemon.js /usr/bin/nodemon && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME

USER 1001
ADD . /app
WORKDIR /app
RUN npm install
RUN apt-get update
RUN apt-get install -y vim
RUN useradd -d /home/term -m -s /bin/bash term
RUN echo 'term:term' | chpasswd

EXPOSE 8888

ENTRYPOINT ["node"]
CMD ["app.js", "-p", "8888"]
