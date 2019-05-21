FROM ubuntu:18.04

# Install software
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gettext \
        openjdk-8-jre \
        tomcat8 \
        tomcat8-admin \
        tomcat8-common \
        tomcat8-docs \
        tomcat8-user \
        unzip \
        zip && \
    rm -rf /var/lib/apt/lists/*

# Prepare tomcat environment for Flamingo
RUN mkdir -p /usr/share/tomcat8/lib && \
    mkdir -p /usr/share/tomcat8/conf && \
    mkdir -p /usr/share/tomcat8/conf/Catalina/localhost && \
    mkdir -p /usr/share/tomcat8/webapps && \
    mkdir -p /opt/flamingo_data && \
    mkdir -p /logs && \
    cp -R /var/lib/tomcat8/conf/* /usr/share/tomcat8/conf/ && \
    cp -R /var/lib/tomcat8/webapps/* /usr/share/tomcat8/webapps/ && \
    ln -s /tmp /usr/share/tomcat8/temp

# Replace tomcat configuration
COPY config/* /opt/
COPY web /opt/

# Download Flamingo
RUN curl "http://central.maven.org/maven2/com/sun/mail/javax.mail/1.5.2/javax.mail-1.5.2.jar" > /usr/share/tomcat8/lib/javax.mail-1.5.2.jar && \
    curl "http://central.maven.org/maven2/postgresql/postgresql/9.1-901.jdbc4/postgresql-9.1-901.jdbc4.jar" > /usr/share/tomcat8/lib/postgresql-9.1-901.jdbc4.jar && \
    curl "https://archive.apache.org/dist/lucene/solr/4.9.1/solr-4.9.1.zip" > /opt/solr-4.9.1.zip && \
    mkdir -p /usr/share/tomcat8/webapps/ && \
    curl "https://repo.b3p.nl/nexus/content/repositories/releases/org/flamingo-mc/viewer/5.2.1/viewer-5.2.1.war" > /usr/share/tomcat8/webapps/viewer.war && \
    curl "https://repo.b3p.nl/nexus/content/repositories/releases/org/flamingo-mc/viewer-admin/5.2.1/viewer-admin-5.2.1.war" > /usr/share/tomcat8/webapps/viewer-admin.war

RUN unzip -d /opt/viewer /usr/share/tomcat8/webapps/viewer.war && \
    cp /opt/login.jsp /opt/viewer/ && \
    cp /opt/change-password.html /opt/viewer/ && \
    cp /opt/ev_sk_splash.jpg /opt/viewer/resources/images/ && \
    cp /opt/logo.png /opt/viewer/WEB-INF/xsl/print/ && \
    cd /opt/viewer && \
    zip -r /opt/viewer.zip . && \
    cp /opt/viewer.zip /usr/share/tomcat8/webapps/viewer.war && \
    rm /opt/viewer.zip && \
    rm -rf /opt/viewer

RUN unzip /opt/solr-4.9.1.zip && \
    cp -r /solr-4.9.1/dist/ /opt/ && \
    cp -r /solr-4.9.1/contrib/ /opt/ && \
    cp  /solr-4.9.1/example/lib/ext/* /usr/share/tomcat8/lib/ && \
    cp  /solr-4.9.1/example/resources/* /usr/share/tomcat8/lib/ && \
    rm -r /solr-4.9.1

EXPOSE 8080 8009

COPY start.sh /opt/
RUN chown -R tomcat8:tomcat8 /usr/share/tomcat8/ && \
    chown -R tomcat8:tomcat8 /opt/flamingo_data/ && \
    chmod u+x /opt/start.sh && \
    chmod -R a+w /logs

HEALTHCHECK CMD exit 0

USER tomcat8
CMD ["/opt/start.sh"]
