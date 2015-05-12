#!/bin/bash

IDROP_WEB_IP_ADDR=$1
SECRETS_FILE=$2
echo "Secrets File is: ${SECRETS_FILE}"

#DOCKER_IP_ADDR=$(ifconfig | tr -s ' ' | grep 172 | cut -d ' ' -f 3 | cut -d ':' -f 2)
export JAVA_HOME=/opt/java
export JRE_HOME=/opt/java/jre
export PATH=$PATH:/opt/java/bin:/opt/java/jre/bin

adduser -g 99 -c "Tomcat Service Account" -s /bin/bash -d /opt/tomcat tomcat
echo "export CATALINA_HOME=\"/opt/tomcat\"" >> ~/.bashrc
source ~/.bashrc
cd /opt/
chown -R tomcat tomcat/

cp /files/idrop-web2.war /opt/tomcat/webapps/
chown tomcat /opt/tomcat/webapps/idrop-web2.war
mkdir /etc/idrop-web
cp /files/idrop-web-config2.groovy /etc/idrop-web/
chown -R tomcat /etc/idrop-web/

sed -i "s/localhost/${IDROP_WEB_IP_ADDR}/g" /etc/idrop-web/idrop-web-config2.groovy

if [ -f ${SECRETS_FILE} ]; then
    #cd /root/.secret/
    # Refresh environment variables derived from updated secrets
    sed -e "s/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g" ${SECRETS_FILE} > /root/.secret/idrop-irods-config.sh
    while read line; do export $line; done < <(cat /root/.secret/idrop-irods-config.sh)
    sed -i "s/idrop.config.preset.host.*/*\/\n idrop.config.preset.host=\"${IDROP_CONFIG_PRESET_HOST}\"/g" /etc/idrop-web/idrop-web-config2.groovy
    sed -i "s/idrop.config.preset.port.*/idrop.config.preset.port=\"${IDROP_CONFIG_PRESET_PORT}\"/g" /etc/idrop-web/idrop-web-config2.groovy
    sed -i "s/idrop.config.preset.zone.*/idrop.config.preset.zone=\"${IDROP_CONFIG_PRESET_ZONE}\"/g" /etc/idrop-web/idrop-web-config2.groovy
    sed -i "s/idrop.config.preset.resource.*/idrop.config.preset.resource=\"${IDROP_CONFIG_PRESET_RESOURCE}\"/g" /etc/idrop-web/idrop-web-config2.groovy
    sed -i "s/idrop.config.preset.authScheme.*/idrop.config.preset.authScheme=\"Standard\"\n\/*/g" /etc/idrop-web/idrop-web-config2.groovy;
fi

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

#IDROP_CONFIG_PRESET_HOST: data.hydroshare.org
#IDROP_CONFIG_PRESET_PORT: 1247
#IDROP_CONFIG_PRESET_ZONE: hydroZone
#IDROP_CONFIG_PRESET_RESOURCE: hydroResource
#
#*/
#idrop.config.preset.host="someHost"
#idrop.config.preset.port="1247"
#idrop.config.preset.zone="someZone"
#idrop.config.preset.resource="someResc"
#/*
