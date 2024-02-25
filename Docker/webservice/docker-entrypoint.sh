#!/bin/bash

set -e



if [ -z "$@" ]; then
  exec /usr/local/bin/supervisord -c /etc/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi