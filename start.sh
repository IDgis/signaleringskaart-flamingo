#!/bin/bash

envsubst < /opt/server.xml > /usr/local/tomcat/conf/server.xml
envsubst < /opt/tomcat-users.xml > /usr/local/tomcat/conf/tomcat-users.xml

envsubst < /opt/viewer.xml > /usr/local/tomcat/conf/Catalina/localhost/viewer.xml
envsubst < /opt/viewer-admin.xml > /usr/local/tomcat/conf/Catalina/localhost/viewer-admin.xml
envsubst < /opt/solr.xml > /usr/local/tomcat/conf/Catalina/localhost/solr.xml

set -e

export CATALINA_OPTS="-Dsolr.solr.home=/opt/flamingo_data/.solr"

exec /usr/local/tomcat/bin/catalina.sh run
