FROM ubuntu:18.04

# Install software
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gettext \
        openjdk-8-jre \
        tomcat 8 && \
    rm -rf /var/lib/apt/lists/*

# Prepare tomcat environment for Flamingo
RUN mkdir -p /usr/share/tomcat8/lib && \
    mkdir -p /usr/share/tomcat8/conf && \
    mkdir -p /usr/share/tomcat8/conf/Catalina/localhost && \
    mkdir -p /opt/flamingo_data && \
    cp -R /var/lib/tomcat8/conf/* /usr/share/tomcat8/conf/ && \
    ln -s /tmp /usr/share/tomcat8/temp

# Replace tomcat configuration
COPY config/* /opt/

# Download Flamingo
RUN curl "http://central.maven.org/maven2/com/sun/mail/javax.mail/1.5.2/javax.mail-1.5.2.jar" > /usr/share/tomcat8/lib/javax.mail-1.5.2.jar && \
    curl "http://central.maven.org/maven2/postgresql/postgresql/9.1-901.jdbc4/postgresql-9.1-901.jdbc4.jar" > /usr/share/tomcat8/lib/postgresql-9.1-901.jdbc4.jar && \
    curl "http://central.maven.org/maven2/org/apache/solr/solr/4.9.1/solr-4.9.1.war" > /opt/flamingo_data/solr.war && \
    mkdir -p /usr/share/tomcat8/webapps/ && \
    curl "http://repo.b3p.nl/nexus/content/repositories/releases/org/flamingo-mc/viewer/4.8.0/viewer-4.8.0.war" > /usr/share/tomcat8/webapps/viewer.war && \
    curl "http://repo.b3p.nl/nexus/content/repositories/releases/org/flamingo-mc/viewer-admin/4.8.0/viewer-admin-4.8.0.war" > /usr/share/tomcat8/webapps/viewer-admin.war

EXPOSE 8080 8009

# Default environment
ENV SERVICE_IDENTIFICATION="flamingo" \
    SERVICE_DOMAIN="localhost" \
    SERVICE_AJP_PORT="8009" \
    SERVICE_HTTP_PORT="8080" \
    SERVICE_PATH="/"

COPY start.sh /opt/
RUN chown -R tomcat8:tomcat8 /usr/share/tomcat8/ && \
    chown -R tomcat8:tomcat8 /opt/flamingo_data/ && \
    chmod u+x /opt/start.sh

HEALTHCHECK CMD exit 0

USER tomcat8
CMD ["/opt/start.sh"]
