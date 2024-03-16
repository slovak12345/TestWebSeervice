FROM gcs-base:0.1
ARG DEBIAN_FRONTEND=noninteractive
EXPOSE 9200 9600 10601 27017
COPY docker-entrypoint.sh /
COPY opt/opensearch/opensearch-tar-install.sh .
COPY thirdparty/scripts/mongodb/create_users.js /tmp
RUN mv opensearch-tar-install.sh /opt/opensearch \
&& mkdir /var/log/fluent-bit && mkdir /var/log/gcs-broker-lora-rtk && mkdir /var/log/gcs-cloud-integration-service && mkdir /var/log/gcs-connection-manager && mkdir /var/log/gcs-dispatch-system && mkdir /var/log/gcs-ui-backend \
&& chown gcs:gcs /var/log/gcs-broker-lora-rtk /var/log/gcs-connection-manager /var/log/gcs-dispatch-system /var/log/gcs-ui-backend \
&& chown gcs-cloud /var/log/gcs-cloud-integration-service \
&& chown fluentbit /var/log/fluent-bit \
&& chmod 755 /var/log/fluent-bit /var/log/gcs-broker-lora-rtk /var/log/gcs-cloud-integration-service /var/log/gcs-connection-manager /var/log/gcs-dispatch-system /var/log/gcs-ui-backend \
&& chmod 700 /var/lib/redis \
&& mkdir /opt/gcs \
&& chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]