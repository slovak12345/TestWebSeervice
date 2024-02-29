FROM ubuntu:22.04

RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries

RUN apt update && apt install -y \
openjdk-11-jdk \
unzip \
wget \
sudo \
curl \
git \
cmake \
nano \
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
python3-venv \
python3-pip \
tcpdump \
nodejs \
lsb-core \
iptables


RUN groupadd opensearch \
&& useradd opensearch -g opensearch -M -s /bin/bash \
&& echo 'opensearch:Docker!' | chpasswd

RUN groupadd fluentbit \
&& useradd fluentbit -g fluentbit -M -s /bin/bash \
&& echo 'fluentbit:Docker!' | chpasswd

RUN groupadd gcs \
&& useradd gcs -g gcs -M -s /bin/bash \
&& echo 'gcs:Docker!' | chpasswd

RUN groupadd gcs-cloud \
&& useradd gcs-cloud -g gcs-cloud -M -s /bin/bash \
&& echo 'gcs-cloud:Docker!' | chpasswd

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

RUN wget https://github.com/fluent/fluent-bit/archive/refs/tags/v2.1.10.zip \
&& unzip v2.1.10.zip \
&& cd fluent-bit-2.1.10/build/ \
&& cmake ../ \
&& make \
&& make install \
&& rm -r /fluent-bit-2.1.10

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

RUN apt-get install gnupg curl

RUN curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y mongodb-org

RUN curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg \
&& echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list \
&& apt-get update \
&& apt-get install redis -y

COPY data/opensearch-dashboards/config/* /opt/opensearch-dashboards/config/
COPY data/opensearch/config/* /opt/opensearch/config/
COPY data/fluent-bit/usr/local/etc/fluent-bit/* /usr/local/etc/fluent-bit/
COPY data/opensearch-cli/config.yaml ~/.opensearch-cli/config.yaml
COPY data/mongodb/mongod.conf /etc/
COPY data/redis/redis.conf /etc/redis/redis.conf

RUN chown -R opensearch:opensearch /opt/opensearch-dashboards/config/ \
&& chown -R opensearch:opensearch /opt/opensearch/config/ \
&& chown -R fluentbit:fluentbit /usr/local/etc/fluent-bit

RUN pip install supervisor
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN mkdir /var/log/fluent-bit && mkdir /var/log/gcs-broker-lora-rtk && mkdir /var/log/gcs-cloud-integration-service && mkdir /var/log/gcs-connection-manager && mkdir /var/log/gcs-dispatch-system && mkdir /var/log/gcs-ui-backend
RUN chown gcs:gcs /var/log/gcs-broker-lora-rtk /var/log/gcs-connection-manager /var/log/gcs-dispatch-system /var/log/gcs-ui-backend
RUN chown gcs-cloud /var/log/gcs-cloud-integration-service
RUN chown fluentbit /var/log/fluent-bit
RUN chmod 755 /var/log/fluent-bit /var/log/gcs-broker-lora-rtk /var/log/gcs-cloud-integration-service /var/log/gcs-connection-manager /var/log/gcs-dispatch-system /var/log/gcs-ui-backend

COPY data/gcs/secrets.yml /opt/gcs/
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && chmod a+x /usr/local/bin/yq && echo "user $(yq '.redis.login' /opt/gcs/secrets.yml) $(echo -n $(yq '.redis.passwd' /opt/gcs/secrets.yml) | sha256sum)" >> /etc/redis/redis.conf && \
chown redis:root /etc/redis/redis.conf && \
chmod 600 /etc/redis/redis.conf && \
chmod 700 /var/lib/redis && \
chown gcs:root /opt/gcs/secrets.yml && \
chmod 600 /opt/gcs/secrets.yml

RUN sed -i "s/myUser/$(yq '.mongodb.login' /opt/gcs/secrets.yml)/g; s/myPassword/$(yq '.mongodb.passwd' /opt/gcs/secrets.yml)/g" /etc/mongodb/create_users.js \
&& chown mongodb:root /etc/mongodb/create_users.js \
&& chown mongodb:root /etc/mongod.conf \
&& chmod 600 /etc/mongod.conf \
&& chmod 600 /etc/mongodb/create_users.js

ENV MONGO_INITDB_ROOT_USERNAME=admin_mdb
ENV MONGO_INITDB_ROOT_PASSWORD=password_mdb

EXPOSE 9200 9600 10601 27017
COPY Docker/webservice/docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]