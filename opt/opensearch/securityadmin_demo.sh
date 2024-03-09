#!/bin/bash
"/opt/opensearch/plugins/opensearch-security/tools/securityadmin.sh" -cd "/opt/gcs/opensearch/config/opensearch-security" -icl -key "/opt/gcs/opensearch/config/certs/server-key.pem" -cert "/opt/gcs/opensearch/config/certs/server-cert.pem" -cacert "/opt/gcs/opensearch/config/certs/ca-cert.pem" -nhnv
