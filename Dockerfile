FROM ubuntu:18.04 as builder

ARG FLAMINGO_VIEWER_VERSION=5.8.14
ARG FLAMINGO_ADMIN_VERSION=5.8.14

COPY web /opt/web
RUN apt-get update \
    && apt-get install -y \
        unzip \
        wget \
        zip \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/jmx_prometheus_javaagent.jar "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar" \
    && wget -O /opt/viewer-admin.war "https://repo.b3p.nl/nexus/repository/public/org/flamingo-mc/viewer-admin/${FLAMINGO_ADMIN_VERSION}/viewer-admin-${FLAMINGO_ADMIN_VERSION}.war" \
    && wget -O /opt/viewer.war "https://repo.b3p.nl/nexus/repository/public/org/flamingo-mc/viewer/${FLAMINGO_VIEWER_VERSION}/viewer-${FLAMINGO_VIEWER_VERSION}.war" \
    && unzip -d /opt/viewer /opt/viewer.war \
    && rm /opt/viewer.war \
    && cp /opt/web/login.jsp /opt/viewer/ \
    && cp /opt/web/ev_sk_splash.jpg /opt/viewer/resources/images/ \
    && cp /opt/web/logo.png /opt/viewer/WEB-INF/xsl/print \
    && cp /opt/web/A0_Landscape.xsl /opt/viewer/WEB-INF/xsl/print/ \
    && cp /opt/web/A0_Portrait.xsl /opt/viewer/WEB-INF/xsl/print/ \
    && cp /opt/web/A3_Landscape.xsl /opt/viewer/WEB-INF/xsl/print/ \
    && cp /opt/web/A3_Portrait.xsl /opt/viewer/WEB-INF/xsl/print/ \
    && cp /opt/web/A4_Landscape.xsl /opt/viewer/WEB-INF/xsl/print/ \
    && cp /opt/web/A4_Portrait.xsl /opt/viewer/WEB-INF/xsl/print/ \
    && cp /opt/web/A5_Landscape.xsl /opt/viewer/WEB-INF/xsl/print/ \
    && cp /opt/web/A5_Portrait.xsl /opt/viewer/WEB-INF/xsl/print/ \
    && cp /opt/web/style.jsp /opt/viewer/viewer-html/common/openlayers/theme/default/ \
    && cd /opt/viewer \
    && zip -r /opt/viewer.war *


FROM tomcat:9.0.52-jre11
LABEL maintainer="Kevin van den Bosch <kevin.van.den.bosch@idgis.nl>"

# Install software
RUN apt-get update \
    && apt-get install -y \
        gettext \
        zip \
    && rm -rf /var/lib/apt/lists/*

# Prepare tomcat environment for Flamingo
RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost \
    && mkdir -p /opt/flamingo_data

# Replace tomcat configuration
COPY config/* /opt/

# Download Flamingo tools
RUN wget -O /usr/local/tomcat/lib/javax.mail-1.5.2.jar "https://repo1.maven.org/maven2/com/sun/mail/javax.mail/1.5.2/javax.mail-1.5.2.jar" \
    && wget -O /usr/local/tomcat/lib/postgresql-42.2.9.jar "https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.9/postgresql-42.2.9.jar" \
    && wget -O /usr/local/tomcat/lib/javax.activation-1.2.0.jar "https://repo1.maven.org/maven2/com/sun/activation/javax.activation/1.2.0/javax.activation-1.2.0.jar" \
    && wget -O /opt/solr-4.9.1.zip "https://archive.apache.org/dist/lucene/solr/4.9.1/solr-4.9.1.zip"

COPY --from=builder /opt/viewer.war /usr/local/tomcat/webapps/viewer.war
COPY --from=builder /opt/viewer-admin.war /usr/local/tomcat/webapps/viewer-admin.war

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

COPY --from=builder /opt/jmx_prometheus_javaagent.jar /usr/local/tomcat/lib/
COPY prometheus.yaml /usr/local/tomcat/lib/

WORKDIR /usr/local/tomcat/lib

USER flamingo
CMD ["/opt/start.sh"]
