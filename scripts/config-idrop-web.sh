#!/bin/bash

IDROP_WEB_IP_ADDR=${1}
IDROP_CONFIG_FILE=/files/${2}

if [ -z ${IDROP_WEB_IP_ADDR} ]; then
    echo *** Using default web address: localhost ***
    IDROP_WEB_IP_ADDR=localhost;
fi

if [ -z ${IDROP_CONFIG_FILE} ]; then
    echo *** Using default config file: idrop-config.yaml ***
    IDROP_CONFIG_FILE=/files/idrop-config.yaml;
fi

# Create tomcat service account
adduser -g 99 -c "Tomcat Service Account" -s /bin/bash -d /opt/tomcat tomcat
echo "export JAVA_HOME=\"/opt/java\"" >> ~/.bashrc
echo "export JRE_HOME=\"/opt/java/jre\"" >> ~/.bashrc
echo "export CATALINA_HOME=\"/opt/tomcat\"" >> ~/.bashrc
echo "export PATH=\"${PATH}:/opt/java/bin:/opt/java/jre/bin\"" >> ~/.bashrc
source ~/.bashrc
cd /opt/
chown -R tomcat tomcat/

# Copy iDrop files to the appropriate location
cp /files/idrop-web2.war /opt/tomcat/webapps/
chown tomcat /opt/tomcat/webapps/idrop-web2.war
mkdir /etc/idrop-web
cp /files/idrop-web-config2.groovy /etc/idrop-web/
chown -R tomcat /etc/idrop-web/

# Update idrop-web-config2.groovy with host information
sed -i "s/localhost/${IDROP_WEB_IP_ADDR}/g" /etc/idrop-web/idrop-web-config2.groovy

# Refresh environment variables derived from updated secrets
sed -e "s/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g" ${IDROP_CONFIG_FILE} > /files/idrop-config.sh
while read line; do export $line; done < <(cat /files/idrop-config.sh)

# Update idrop-web-config2.groovy with configuration presets
sed -i "s/idrop.config.preset.host.*/*\/\n idrop.config.preset.host=\"${IDROP_CONFIG_PRESET_HOST}\"/g" /etc/idrop-web/idrop-web-config2.groovy
sed -i "s/idrop.config.preset.port.*/idrop.config.preset.port=\"${IDROP_CONFIG_PRESET_PORT}\"/g" /etc/idrop-web/idrop-web-config2.groovy
sed -i "s/idrop.config.preset.zone.*/idrop.config.preset.zone=\"${IDROP_CONFIG_PRESET_ZONE}\"/g" /etc/idrop-web/idrop-web-config2.groovy
sed -i "s/idrop.config.preset.resource.*/idrop.config.preset.resource=\"${IDROP_CONFIG_PRESET_RESOURCE}\"/g" /etc/idrop-web/idrop-web-config2.groovy
sed -i "s/idrop.config.preset.authScheme.*/idrop.config.preset.authScheme=\"Standard\"\n\/*/g" /etc/idrop-web/idrop-web-config2.groovy;

su tomcat <<'EOF'
export JAVA_HOME=/opt/java
export JRE_HOME=/opt/java/jre
export PATH=$PATH:/opt/java/bin:/opt/java/jre/bin
/opt/tomcat/bin/shutdown.sh
sleep 1s
/opt/tomcat/bin/startup.sh
EOF

# keep server running
/usr/bin/tail -f /dev/null
