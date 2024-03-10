FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
EXPOSE 9200 9600 10601 27017
COPY docker-entrypoint.sh /
COPY opt/opensearch/opensearch-tar-install.sh .
COPY thirdparty/scripts/create_users.js /tmp
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries \
&& apt update && apt install -y \
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
iptables \
gnupg \
curl \
cargo \
libclang-dev \
&& groupadd opensearch \
&& useradd opensearch -g opensearch -M -s /bin/bash \
&& echo 'opensearch:Docker!' | chpasswd \
&& groupadd fluentbit \
&& useradd fluentbit -g fluentbit -M -s /bin/bash \
&& echo 'fluentbit:Docker!' | chpasswd \
&& groupadd gcs \
&& useradd gcs -g gcs -M -s /bin/bash \
&& echo 'gcs:Docker!' | chpasswd \
&& groupadd gcs-cloud \
&& useradd gcs-cloud -g gcs-cloud -M -s /bin/bash \
&& echo 'gcs-cloud:Docker!' | chpasswd \
&& wget https://artifacts.opensearch.org/releases/bundle/opensearch/2.9.0/opensearch-2.9.0-linux-x64.tar.gz \
&& chmod +x opensearch-2.9.0-linux-x64.tar.gz \
&& tar -xf opensearch-2.9.0-linux-x64.tar.gz \
&& mkdir /opt/opensearch \
&& mv ./opensearch-2.9.0/* /opt/opensearch \
&& rmdir ./opensearch-2.9.0 \
&& mkdir /var/log/opensearch \
&& chown -R opensearch /var/log/opensearch \
&& rm opensearch-2.9.0-linux-x64.tar.gz \
&& mv opensearch-tar-install.sh /opt/opensearch \
&& chown -R opensearch:opensearch /opt/opensearch
RUN wget https://github.com/fluent/fluent-bit/archive/refs/tags/v2.1.10.zip \
&& unzip v2.1.10.zip \
&& cd fluent-bit-2.1.10/build/ \
&& cmake ../ \
&& make \
&& make install \
&& rm -r /fluent-bit-2.1.10 \
&& cd /
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
RUN curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor \
&& echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list \
&& apt-get update \
&& apt-get install -y mongodb-org
RUN curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg \
&& echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list \
&& sudo apt-get update \
&& sudo apt-get -y install redis=6:7.2.4-1rl1~jammy1 \
&& sudo mkdir /var/lib/redis/modules
RUN wget https://github.com/RedisJSON/RedisJSON/archive/refs/tags/v2.6.6.zip \
&& unzip v2.6.6.zip \
&& cd RedisJSON-2.6.6 \
&& cargo build --release \
&& sudo cp ./target/release/librejson.so /var/lib/redis/modules \
&& cd /
RUN git clone -b v2.8.5 --recursive https://github.com/RediSearch/RediSearch.git RediSearch-v2.8.5 \
&& cd RediSearch-v2.8.5 \
&& make setup \
&& make build \
&& sudo cp ./bin/linux-x64-release/search/redisearch.so /var/lib/redis/modules \
&& sudo chmod +777 /var/lib/redis/modules/librejson.so \
&& sudo chmod +777 /var/lib/redis/modules/redisearch.so \
&& cd / \
&& pip install supervisor \
&& mkdir /var/log/fluent-bit && mkdir /var/log/gcs-broker-lora-rtk && mkdir /var/log/gcs-cloud-integration-service && mkdir /var/log/gcs-connection-manager && mkdir /var/log/gcs-dispatch-system && mkdir /var/log/gcs-ui-backend \
&& chown gcs:gcs /var/log/gcs-broker-lora-rtk /var/log/gcs-connection-manager /var/log/gcs-dispatch-system /var/log/gcs-ui-backend \
&& chown gcs-cloud /var/log/gcs-cloud-integration-service \
&& chown fluentbit /var/log/fluent-bit \
&& chmod 755 /var/log/fluent-bit /var/log/gcs-broker-lora-rtk /var/log/gcs-cloud-integration-service /var/log/gcs-connection-manager /var/log/gcs-dispatch-system /var/log/gcs-ui-backend \
&& cd /
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && chmod a+x /usr/local/bin/yq \
&& chmod 700 /var/lib/redis \
&& mkdir /opt/gcs \
&& cd /usr/src \
&& wget https://www.python.org/ftp/python/3.11.5/Python-3.11.5.tgz \   
&& tar -xzf Python-3.11.5.tgz \
&& cd Python-3.11.5 \
&& ./configure --enable-optimizations \
&& make altinstall \
&& update-alternatives --install /usr/bin/python python /usr/local/bin/python3.11 1 \
&& cd / \
&& rm -r RediSearch-v2.8.5 RedisJSON-v2.6.6 \
&& chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]