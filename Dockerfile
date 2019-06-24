FROM ubuntu:18.04 as metrics
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*
RUN curl "http://central.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar" > /opt/jmx_prometheus_javaagent.jar

FROM maven:3.6-jdk-8 as builder
COPY web /opt/web
RUN curl -L "https://github.com/flamingo-geocms/flamingo/archive/v5.2.1.zip" > /opt/flamingo.zip \
    && unzip -d /opt/flamingo /opt/flamingo.zip \
    && cp /opt/web/login.jsp /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/ \
    && cp /opt/web/ev_sk_splash.jpg /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/resources/images/ \
    && cp /opt/web/logo.png /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A0_Landscape.xsl /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A0_Portrait.xsl /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A3_Landscape.xsl /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A3_Portrait.xsl /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A4_Landscape.xsl /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A4_Portrait.xsl /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A5_Landscape.xsl /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A5_Portrait.xsl /opt/flamingo/flamingo-5.2.1/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && touch /opt/flamingo/flamingo-5.2.1/viewer-admin/src/main/resources/git.properties \
    && mkdir -p /opt/flamingo/flamingo-5.2.1/viewer/src/main/resources \
    && touch /opt/flamingo/flamingo-5.2.1/viewer/src/main/resources/git.properties \
    && cd /opt/flamingo/flamingo-5.2.1 \
    && mvn install -Dmaven.test.skip=true


FROM ubuntu:18.04

# Install software
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        gettext \
        openjdk-8-jre \
        tomcat8 \
        tomcat8-admin \
        tomcat8-common \
        tomcat8-docs \
        tomcat8-user \
        unzip \
        zip \
    && rm -rf /var/lib/apt/lists/*

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

COPY --from=metrics /opt/jmx_prometheus_javaagent.jar /usr/share/tomcat8/lib/
COPY prometheus.yaml /usr/share/tomcat8/lib/

# Download Flamingo
RUN curl "http://central.maven.org/maven2/com/sun/mail/javax.mail/1.5.2/javax.mail-1.5.2.jar" > /usr/share/tomcat8/lib/javax.mail-1.5.2.jar && \
    curl "http://central.maven.org/maven2/org/postgresql/postgresql/42.2.5/postgresql-42.2.5.jar" > /usr/share/tomcat8/lib/postgresql-42.2.5.jar && \
    curl "https://archive.apache.org/dist/lucene/solr/4.9.1/solr-4.9.1.zip" > /opt/solr-4.9.1.zip && \
    mkdir -p /usr/share/tomcat8/webapps/

COPY --from=builder /opt/flamingo/flamingo-5.2.1/viewer/target/viewer-5.2.1.war /usr/share/tomcat8/webapps/viewer.war
COPY --from=builder /opt/flamingo/flamingo-5.2.1/viewer-admin/target/viewer-admin-5.2.1.war /usr/share/tomcat8/webapps/viewer-admin.war

RUN unzip /opt/solr-4.9.1.zip && \
    cp -r /solr-4.9.1/dist/ /opt/ && \
    cp -r /solr-4.9.1/contrib/ /opt/ && \
    cp  /solr-4.9.1/example/lib/ext/* /usr/share/tomcat8/lib/ && \
    cp  /solr-4.9.1/example/resources/* /usr/share/tomcat8/lib/ && \
    rm -r /solr-4.9.1

EXPOSE 8080 8009 9090

COPY start.sh /opt/
RUN chown -R tomcat8:tomcat8 /usr/share/tomcat8/ && \
    chown -R tomcat8:tomcat8 /opt/flamingo_data/ && \
    chmod u+x /opt/start.sh && \
    chmod -R a+w /logs

HEALTHCHECK CMD exit 0

WORKDIR /usr/share/tomcat8/lib

USER tomcat8
CMD ["/opt/start.sh"]
