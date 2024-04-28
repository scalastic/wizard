FROM jenkins/jenkins:latest

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /jenkins/casc_configs

COPY "${JENKINS_INSTALLATION_CONFIG}/plugins.txt" /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

COPY "${JENKINS_INSTALLATION_CONFIG}/secrets.properties" /run/secrets/secrets.properties

COPY "${JENKINS_INSTALLATION_CONFIG}/casc.yaml" /jenkins/casc_configs/jenkins.yaml
