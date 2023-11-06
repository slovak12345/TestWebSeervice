#!/bin/sh

/bin/bash
sudo /usr/bin/mongod --config /etc/mongod.conf &
fluent-bit -c /usr/local/etc/fluent-bit/fluent-bit.conf &
sudo -u opensearch /opt/opensearch/opensearch-tar-install.sh -Ecluster.name=opensearch-cluster -Enode.name=opensearch-node1 -Ehttp.host=0.0.0.0 -Ediscovery.type=single-node &
sudo -u opensearch /opt/opensearch-dashboards/bin/opensearch-dashboards 