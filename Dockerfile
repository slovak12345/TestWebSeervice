FROM ubuntu:22.04

RUN apt update && apt install -y \
openjdk-11-jdk \
unzip \
wget \
sudo \
curl \
git \
cmake \
pkg-config \
flex \ 
bison \
libyaml-0-2 \
build-essential \
libssl-dev \
libyaml-dev \
libedit-dev \
libsystemd-dev

RUN groupadd opensearch \
&& useradd opensearch -g opensearch -M -s /bin/bash \
&& echo 'opensearch:Docker!' | chpasswd

RUN groupadd logstash \
&& useradd logstash -g logstash -M -s /bin/bash \
&& echo 'logstash:Docker!' | chpasswd

COPY opensearch.service /lib/systemd/system/

RUN wget https://artifacts.opensearch.org/releases/bundle/opensearch/2.9.0/opensearch-2.9.0-linux-x64.tar.gz \
&& chmod +x opensearch-2.9.0-linux-x64.tar.gz \
&& tar -xf opensearch-2.9.0-linux-x64.tar.gz \
&& mkdir /opt/opensearch \
&& mv ./opensearch-2.9.0/* /opt/opensearch \
&& rmdir ./opensearch-2.9.0 \
&& chown -R opensearch:opensearch /opt/opensearch \
&& chown -R root:root /lib/systemd/system/opensearch.service \
&& mkdir /var/log/opensearch \
&& chown -R opensearch /var/log/opensearch

RUN git clone https://github.com/fluent/fluent-bit \
&& cd fluent-bit/build/ \
&& cmake ../ \
&& make \
&& make install

COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]