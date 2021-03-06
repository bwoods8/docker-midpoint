FROM centos:7

ENV MIDPOINT_VERSION 3.7

WORKDIR /tmp

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
  INSTALL_PKGS="curl \
  iputils \
  java-1.8.0-openjdk-headless \
  less \
  tar \
  unzip \
  wget \
  yum-utils" && \
  yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
  rpm -V $INSTALL_PKGS && \
  yum clean all -y && rm -rf /var/cache/yum

RUN wget https://evolveum.com/downloads/midpoint/${MIDPOINT_VERSION}/midpoint-${MIDPOINT_VERSION}-dist.tar.gz
	
RUN groupadd midpoint \
    && adduser -d /opt/midpoint \
    -s /sbin/nologin \
    -c "midPoint User" \
    -g midpoint \
    midpoint

RUN mkdir -p /opt/midpoint/var && chown -R midpoint:midpoint /opt/midpoint/var

RUN mkdir -p /opt/midpoint/config && chown -R midpoint:midpoint /opt/midpoint/config

VOLUME [ "/opt/midpoint/config", "/opt/midpoint/var" ]

WORKDIR /opt/midpoint

USER midpoint

RUN tar zxf /tmp/midpoint-${MIDPOINT_VERSION}-dist.tar.gz -C /opt/midpoint --strip-components=1

EXPOSE 8080

ENTRYPOINT exec java ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom -Dfile.encoding=UTF8 -Dmidpoint.home=/opt/midpoint/var -jar /opt/midpoint/lib/midpoint.war
