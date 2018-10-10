#!/bin/bash

envsubst < /opt/server.xml > /usr/share/tomcat8/conf/server.xml

envsubst < /opt/solr.xml > /usr/share/tomcat8/conf/Catalina/localhost/solr.xml
envsubst < /opt/viewer.xml > /usr/share/tomcat8/conf/Catalina/localhost/viewer.xml
envsubst < /opt/viewer-admin.xml > /usr/share/tomcat8/conf/Catalina/localhost/viewer-admin.xml

set -e

JAVA_OPTS="-Djava.net.preferIPv4Stack=true"
JAVA_OPTS="$JAVA_OPTS -Dservice.identification=$SERVICE_IDENTIFICATION"
JAVA_OPTS="$JAVA_OPTS -Dservice.domain=$SERVICE_DOMAIN"
JAVA_OPTS="$JAVA_OPTS -Dservice.ajpPort=$SERVICE_AJP_PORT"
JAVA_OPTS="$JAVA_OPTS -Dservice.httpPort=$SERVICE_HTTP_PORT"
JAVA_OPTS="$JAVA_OPTS -Dservice.path=$SERVICE_PATH"
export JAVA_OPTS

exec /usr/share/tomcat8/bin/catalina.sh run
