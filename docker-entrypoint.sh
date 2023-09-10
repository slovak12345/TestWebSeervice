#!/bin/sh
/bin/bash
fluent-bit -c /usr/local/etc/fluent-bit/fluent-bit.conf &

sudo -u opensearch /opt/opensearch/opensearch-tar-install.sh &
sudo -u opensearch /opt/opensearch-dashboards/bin/opensearch-dashboards 
