#!/bin/bash
sudo iptables -A INPUT -s 127.0.0.1/32 -i eth0 -p tcp -m tcp --dport 6379 -j ACCEPT && \
sudo iptables -A INPUT -i eth0 -p tcp -m tcp --dport 6379 -j DROP

sudo iptables -A INPUT -s 127.0.0.1/32 -i eth0 -p tcp -m tcp --dport 27017 -j ACCEPT && \
sudo iptables -A INPUT -i eth0 -p tcp -m tcp --dport 27017 -j DROP

set -e

sudo chown -R opensearch:opensearch /opt/gcs/opensearch-dashboards/config/
sudo chown -R opensearch:opensearch /opt/gcs/opensearch/config/
sudo chown -R fluentbit:fluentbit /opt/gcs/fluent-bit
sudo chown redis:root /opt/gcs/redis/redis.conf
sudo chmod 600 /opt/gcs/redis/gcs/redis.conf
sudo chown gcs:root /opt/gcs/secrets/redis_secrets.yml
sudo chmod 600 /opt/gcs/secrets/redis_secrets.yml
sudo chown mongodb:root /opt/gcs/mongod.conf
sudo chmod 600 /opt/gcs/mongod.conf

echo "user $(yq -r '.redis.login' /opt/gcs/secrets/redis_secrets.yml) on ~* &* +@all #$(echo -n $(yq -r '.redis.passwd' /opt/gcs/secrets/redis_secrets.yml) | sha256sum | head -c 64)" >> /opt/gcs/redis/redis.conf

if [ -z "$@" ]; then
  exec /usr/local/bin/supervisord -c /opt/gcs/supervisord/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi

mongosh < /opt/gcs/secrets/create_users.js