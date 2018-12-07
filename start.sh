#!/bin/bash

envsubst < /opt/server.xml > /usr/share/tomcat8/conf/server.xml
envsubst < /opt/tomcat-users.xml > /usr/share/tomcat8/conf/tomcat-users.xml

envsubst < /opt/viewer.xml > /usr/share/tomcat8/conf/Catalina/localhost/viewer.xml
envsubst < /opt/viewer-admin.xml > /usr/share/tomcat8/conf/Catalina/localhost/viewer-admin.xml
envsubst < /opt/solr.xml > /usr/share/tomcat8/conf/Catalina/localhost/solr.xml

set -e

export CATALINA_OPTS="-Dsolr.solr.home=/opt/flamingo_data/.solr"

exec /usr/share/tomcat8/bin/catalina.sh run
