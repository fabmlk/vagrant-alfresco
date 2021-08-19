#! /usr/bin/env bash

set -x


####################
# Install ALFRESCO #
####################

wget -O alfresco.bin https://download.alfresco.com/release/community/201707-build-00028/alfresco-community-installer-201707-linux-x64.bin

# create alfresco install dir
mkdir /opt/alfresco

# install dependencies
apt-get -y install libfontconfig1 libsm6 libice6 libxrender1 libxt6 libcups2

# add locale fr
sed -i 's/# fr_FR.UTF-8/fr_FR.UTF-8/' /etc/locale.gen && locale-gen && localectl set-locale LANG=fr_FR.utf8

# execute installer
chmod +x alfresco.bin
# https://docs.alfresco.com/5.2/concepts/silent-alf-install.html
./alfresco.bin --optionfile /vagrant/provision/alfresco_install_opts





######################
# Configure Alfresco #
######################

cat >>/opt/alfresco/tomcat/shared/classes/alfresco-global.properties <<EOL

### Remote User authentication ###
authentication.chain=external1:external,alfrescoNtlm1:alfrescoNtlm
external.authentication.proxyUserName=
external.authentication.enabled=true
external.authentication.defaultAdministratorUserNames=admin
external.authentication.proxyHeader=X-Alfresco-Remote-User
EOL

# disable ssl config + fill-in User Header
sed -i -e '/<ssl-config>/ i <!--' -e '/<\/ssl-config>/ a -->' \
    -e 's/SsoUserHeader/X-Alfresco-Remote-User/' /opt/alfresco/tomcat/shared/classes/alfresco/web-extension/share-config-custom.xml

# fetch SDK jars from gitlab
GITLAB_URL=https://gitlab.tms-soft.fr
PROJECT_REF=0.0.2
JAR_VERSION=1.0-SNAPSHOT
curl "$GITLAB_URL/api/v4/projects/80/jobs/artifacts/$PROJECT_REF/raw/tms-alfresco-platform-jar/target/tms-alfresco-platform-jar-$JAR_VERSION.jar?job=release" \
    -H "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
    --output /opt/alfresco/modules/platform/tms-alfresco-platform-jar-$JAR_VERSION.jar
curl "$GITLAB_URL/api/v4/projects/80/jobs/artifacts/$PROJECT_REF/raw/tms-alfresco-share-jar/target/tms-alfresco-share-jar-$JAR_VERSION.jar?job=release" \
    -H "PRIVATE-TOKEN: $GITLAB_PRIVATE_TOKEN" \
    --output /opt/alfresco/modules/share/tms-alfresco-share-jar-$JAR_VERSION.jar

# postgresql external access (http://www.jouvinio.net/wiki/index.php/Connexion_machine_distante_PostgreSql)
echo 'listen_addresses = '\''*'\' >> /opt/alfresco/alf_data/postgresql/postgresql.conf
echo 'host    all             all             192.168.46.0/24         md5' >> /opt/alfresco/alf_data/postgresql/pg_hba.conf




#####################
# Configure NetBIOS #
#####################

# on veut activer NSS pour netbios
apt-get install -y libnss-winbind
sed -i 's/dns/wins dns/' /etc/nsswitch.conf

# libnss-winbind a remplace samba package mais on a besoin de son nmbd daemon pour implementer name resolution via broadcast
#apt-get install -y samba

