FROM centos:centos6.6

MAINTAINER Michael Stealey <michael.j.stealey@gmail.com>

ENV TERM xterm

RUN yum install -y wget tar sudo
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -Uvh epel-release-6*.rpm

ADD scripts /scripts
WORKDIR /scripts
RUN chmod a+x *.sh

ADD files /files
WORKDIR /files

EXPOSE 8080

# Keep container from shutting down until explicitly stopped
ENTRYPOINT ["/scripts/config-idrop-web.sh"]
