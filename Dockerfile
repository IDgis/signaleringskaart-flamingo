FROM ubuntu:18.04 as metrics
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*
RUN curl "http://central.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar" > /opt/jmx_prometheus_javaagent.jar

FROM maven:3.6-jdk-8 as builder
COPY web /opt/web

ARG FLAMINGO_VERSION=5.4.6

RUN curl -L "https://github.com/flamingo-geocms/flamingo/archive/v${FLAMINGO_VERSION}.zip" > /opt/flamingo.zip \
    && unzip -d /opt/flamingo /opt/flamingo.zip \
    && cp /opt/web/login.jsp /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/ \
    && cp /opt/web/ev_sk_splash.jpg /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/resources/images/ \
    && cp /opt/web/logo.png /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A0_Landscape.xsl /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A0_Portrait.xsl /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A3_Landscape.xsl /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A3_Portrait.xsl /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A4_Landscape.xsl /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A4_Portrait.xsl /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A5_Landscape.xsl /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/A5_Portrait.xsl /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/WEB-INF/xsl/print/ \
    && cp /opt/web/style.jsp /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/webapp/viewer-html/common/openlayers/theme/default/ \
    && touch /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer-admin/src/main/resources/git.properties \
    && mkdir -p /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/resources \
    && touch /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/src/main/resources/git.properties \
    && cd /opt/flamingo/flamingo-${FLAMINGO_VERSION} \
    && mvn install -Dmaven.test.skip=true


FROM tomcat:9.0-jre8
LABEL maintainer="Kevin van den Bosch <kevin.van.den.bosch@idgis.nl>"

ARG FLAMINGO_VERSION=5.4.6

# Install software
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        gettext \
        unzip \
        zip \
    && rm -rf /var/lib/apt/lists/*

# Prepare tomcat environment for Flamingo
RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost \
    && mkdir -p /opt/flamingo_data

# Replace tomcat configuration
COPY config/* /opt/

#Download Flamingo
RUN curl "http://central.maven.org/maven2/com/sun/mail/javax.mail/1.5.2/javax.mail-1.5.2.jar" > /usr/local/tomcat/lib/javax.mail-1.5.2.jar && \
    curl "http://central.maven.org/maven2/org/postgresql/postgresql/42.2.5/postgresql-42.2.5.jar" > /usr/local/tomcat/lib/postgresql-42.2.5.jar && \
    curl "https://archive.apache.org/dist/lucene/solr/4.9.1/solr-4.9.1.zip" > /opt/solr-4.9.1.zip

COPY --from=builder /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer/target/viewer-${FLAMINGO_VERSION}.war /usr/local/tomcat/webapps/viewer.war
COPY --from=builder /opt/flamingo/flamingo-${FLAMINGO_VERSION}/viewer-admin/target/viewer-admin-${FLAMINGO_VERSION}.war /usr/local/tomcat/webapps/viewer-admin.war

RUN unzip -d / /opt/solr-4.9.1.zip && \
    cp -r /solr-4.9.1/dist/ /opt/ && \
    cp -r /solr-4.9.1/contrib/ /opt/ && \
    cp  /solr-4.9.1/example/lib/ext/* /usr/local/tomcat/lib/ && \
    cp  /solr-4.9.1/example/resources/* /usr/local/tomcat/lib/ && \
    rm -r /solr-4.9.1

EXPOSE 8080 8009 9090

COPY start.sh /opt/
RUN groupadd -r flamingo && useradd --no-log-init -r -g flamingo flamingo \
    && chown -R flamingo:flamingo /usr/local/tomcat/ \
    && chown -R flamingo:flamingo /opt/flamingo_data/ \
    && chmod u+x /opt/start.sh

COPY --from=metrics /opt/jmx_prometheus_javaagent.jar /usr/local/tomcat/lib/
COPY prometheus.yaml /usr/local/tomcat/lib/

HEALTHCHECK CMD exit 0

WORKDIR /usr/local/tomcat/lib

USER flamingo
CMD ["/opt/start.sh"]
