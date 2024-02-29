#!/bin/bash
sudo iptables -A INPUT -s 127.0.0.1/32 -i eth0 -p tcp -m tcp --dport 6379 -j ACCEPT && \
sudo iptables -A INPUT -i eth0 -p tcp -m tcp --dport 6379 -j DROP

sudo iptables -A INPUT -s 127.0.0.1/32 -i eth0 -p tcp -m tcp --dport 27017 -j ACCEPT && \
sudo iptables -A INPUT -i eth0 -p tcp -m tcp --dport 27017 -j DROP

set -e

echo "user $(yq '.redis.login' /opt/gcs/secrets.yml) on ~* &* +@all #$(echo -n $(yq '.redis.passwd' /opt/gcs/secrets.yml) | sha256sum)" >> /opt/redis/redis.conf
sed -i "s/myUser/$(yq '.mongodb.login' /opt/gcs/secrets.yml)/g; s/myPassword/$(yq '.mongodb.passwd' /opt/gcs/secrets.yml)/g" /opt/mongodb/create_users.js

if [ -z "$@" ]; then
  exec /usr/local/bin/supervisord -c /opt/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi

mongosh < /opt/mongodb/create_users.js