#!/bin/bash
"/opt/opensearch/plugins/opensearch-security/tools/securityadmin.sh" -cd "/opt/gcs/opensearch/config/opensearch-security" -icl -key "/opt/gcs/opensearch/config/kirk-key.pem" -cert "/opt/gcs/opensearch/config/kirk.pem" -cacert "/opt/gcs/opensearch/config/root-ca.pem" -nhnv
