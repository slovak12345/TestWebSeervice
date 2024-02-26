#!/bin/bash
sudo iptables -A INPUT -s 127.0.0.1/32 -i eth0 -p tcp -m tcp --dport 6379 -j ACCEPT && \
sudo iptables -A INPUT -i eth0 -p tcp -m tcp --dport 6379 -j DROP

set -e



if [ -z "$@" ]; then
  exec /usr/local/bin/supervisord -c /etc/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi