#!/bin/bash
"/opt/opensearch/plugins/opensearch-security/tools/securityadmin.sh" -cd "/opt/opensearch/config/opensearch-security" -icl -key "/opt/opensearch/config/kirk-key.pem" -cert "/opt/opensearch/config/kirk.pem" -cacert "/opt/opensearch/config/root-ca.pem" -nhnv
