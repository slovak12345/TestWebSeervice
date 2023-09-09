#!/bin/sh
/bin/bash
fluent-bit &

sudo -u opensearch /opt/opensearch/opensearch-tar-install.sh &
sudo -u opensearch /opt/opensearch-dashboards/bin/opensearch-dashboards 
