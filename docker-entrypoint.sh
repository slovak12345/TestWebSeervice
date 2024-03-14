#!/bin/bash
sudo iptables -A INPUT -s 127.0.0.1/32 -i eth0 -p tcp -m tcp --dport 6379 -j ACCEPT && \
sudo iptables -A INPUT -i eth0 -p tcp -m tcp --dport 6379 -j DROP

sudo iptables -A INPUT -s 127.0.0.1/32 -i eth0 -p tcp -m tcp --dport 27017 -j ACCEPT && \
sudo iptables -A INPUT -i eth0 -p tcp -m tcp --dport 27017 -j DROP

set -e

# sudo chown -R opensearch:opensearch /opt/gcs/opensearch-dashboards/config/
# sudo chown -R opensearch:opensearch /opt/gcs/opensearch/config/
# sudo chmod 700 -R /opt/gcs/opensearch/config/
# sudo chown -R fluentbit:fluentbit /opt/gcs/fluent-bit
# sudo chown redis:root /opt/gcs/redis/redis.conf
# sudo chmod 600 /opt/gcs/redis/redis.conf
# sudo chown gcs:root /opt/gcs/secrets/redis_secrets.yml
# sudo chmod 600 /opt/gcs/secrets/redis_secrets.yml
# sudo chown mongodb:root /opt/gcs/mongodb/mongod.conf
# sudo chmod 600 /opt/gcs/mongodb/mongod.conf

redis_user_login=$(yq -r '.redis.login' /opt/gcs/secrets/secrets.yml)
redis_user_passwd=$(echo -n $(yq -r '.redis.password' /opt/gcs/secrets/secrets.yml) | sha256sum | head -c 64)

redis_user_string="user $redis_user_login on ~* &* +@all #$redis_user_passwd"

sed -i "s|gcs_user_template|$redis_user_string|" /opt/gcs/redis/redis.conf > /opt/gcs/redis/redis.conf.new
rm  /opt/gcs/redis/redis.conf
mv  /opt/gcs/redis/redis.conf.new  /opt/gcs/redis/redis.conf

sed -i "s/myUser/$(yq '.mongodb.login' /opt/gcs/secrets/secrets.yml)/g; s/myPassword/$(yq '.mongodb.password' /opt/gcs/secrets/secrets.yml)/g" /tmp/create_users.js
if [ -z "$@" ]; then
  exec /usr/local/bin/supervisord -c /opt/gcs/supervisord/supervisord.conf --nodaemon
  sleep 50
  mongosh < /tmp/create_users.js
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi