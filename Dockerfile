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
libsystemd-dev \
python3 \
pip \
python3-venv 

RUN groupadd opensearch \
&& useradd opensearch -g opensearch -M -s /bin/bash \
&& echo 'opensearch:Docker!' | chpasswd

RUN groupadd logstash \
&& useradd logstash -g logstash -M -s /bin/bash \
&& echo 'logstash:Docker!' | chpasswd

RUN groupadd fluentbit \
&& useradd fluentbit -g fluentbit -M -s /bin/bash \
&& echo 'fluentbit:Docker!' | chpasswd

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
&& chown -R opensearch /var/log/opensearch \
&& rm opensearch-2.9.0-linux-x64.tar.gz

RUN git clone https://github.com/fluent/fluent-bit \
&& cd fluent-bit/build/ \
&& cmake ../ \
&& make \
&& make install \
&& rm -r /fluent-bit

RUN wget https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.9.0/opensearch-dashboards-2.9.0-linux-x64.tar.gz \
&& chmod +x opensearch-dashboards-2.9.0-linux-x64.tar.gz \
&& tar -xf opensearch-dashboards-2.9.0-linux-x64.tar.gz \
&& mkdir /opt/opensearch-dashboards \
&& mv ./opensearch-dashboards-2.9.0/* /opt/opensearch-dashboards \
&& rm -r ./opensearch-dashboards-2.9.0 \
&& chown -R opensearch:opensearch /opt/opensearch-dashboards \
&& mkdir /var/log/opensearch-dashboards \
&& chown -R opensearch /var/log/opensearch-dashboards \
&& rm opensearch-dashboards-2.9.0-linux-x64.tar.gz

RUN wget https://artifacts.opensearch.org/opensearch-clients/opensearch-cli/opensearch-cli-1.1.0-linux-x64.zip \
&& chmod +x opensearch-cli-1.1.0-linux-x64.zip \
&& unzip opensearch-cli-1.1.0-linux-x64.zip -d opensearch-cli-1.1.0 \
&& mkdir /opt/opensearch-cli \
&& mv ./opensearch-cli-1.1.0/* /opt/opensearch-cli \
&& rm -r ./opensearch-cli-1.1.0 \
&& chown -R opensearch:opensearch /opt/opensearch-cli \
&& mkdir /var/log/opensearch-cli \
&& chown -R opensearch /var/log/opensearch-cli \
&& rm opensearch-cli-1.1.0-linux-x64.zip


COPY data/opensearch-dashboards/config/* /opt/opensearch-dashboards/config
COPY data/opensearch/config/* /opt/opensearch/config/
COPY data/fluent-bit/usr/local/etc/fluent-bit/* /usr/local/etc/fluent-bit
COPY data/opensearch-cli/config.yaml ~/.opensearch-cli/config.yaml

RUN chown -R opensearch:opensearch /opt/opensearch-dashboards/config/ \
&& chown -R opensearch:opensearch /opt/opensearch/config/ \
&& chown -R fluentbit:fluentbit /usr/local/etc/fluent-bit

EXPOSE 9200 5601 9600 10601
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]