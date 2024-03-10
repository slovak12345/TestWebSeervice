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

redis_user_login=$(yq -r '.redis.login' /opt/gcs/secrets/redis_secrets.yml)
redis_user_passwd=$(echo -n $(yq -r '.redis.password' /opt/gcs/secrets/redis_secrets.yml) | sha256sum | head -c 64)

redis_user_string="user $redis_user_login on ~* &* +@all #$redis_user_passwd"

if grep -q "^user $redis_user_login" /opt/gcs/redis/redis.conf; then
    echo "user $redis_user_login exist in redis"
else
    echo "$redis_user_string" >> /opt/gcs/redis/redis.conf
fi

cp /opt/gcs/mongodb/create_users.js /opt/gcs/mongodb/create_users_m.js
sed -i "s/myUser/$(yq '.mongodb.login' /opt/gcs/secrets/mongodb_secrets.yml)/g; s/myPassword/$(yq '.mongodb.password' /opt/gcs/secrets/mongodb_secrets.yml)/g" /opt/gcs/mongodb/create_users_m.js
if [ -z "$@" ]; then
  exec /usr/local/bin/supervisord -c /opt/gcs/supervisord/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi

mongosh < /opt/gcs/mongodb/create_users_m.js
rm /opt/gcs/mongodb/create_users_m.js