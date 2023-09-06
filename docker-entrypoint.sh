#!/bin/sh

fluent-bit &

sudo -u opensearch /opt/opensearch/opensearch-tar-install.sh -Ecluster.name=opensearch-cluster -Enode.name=opensearch-node1 -Ehttp.host=0.0.0.0 -Ediscovery.type=single-node
