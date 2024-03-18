FROM gcs-base:0.1
ARG DEBIAN_FRONTEND=noninteractive
EXPOSE 9200 9600 10601 27017
COPY docker-entrypoint.sh /
COPY thirdparty/scripts/mongodb/create_users.js /tmp
RUN mkdir /var/log/fluent-bit && mkdir /var/log/gcs-cloud-integration-service \
&& chown gcs-cloud /var/log/gcs-cloud-integration-service \
&& chown fluentbit /var/log/fluent-bit \
&& chmod 755 /var/log/fluent-bit /var/log/gcs-cloud-integration-service \
&& chmod 700 /var/lib/redis \
&& mkdir /opt/gcs \
&& chmod 755 /docker-entrypoint.sh
EXPOSE 14550-20000
ENTRYPOINT ["/docker-entrypoint.sh"]