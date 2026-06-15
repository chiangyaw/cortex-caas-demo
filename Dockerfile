# 1. Base image vulnerable to Spring4Shell
FROM tomcat:9.0.59-jdk11-openjdk-slim

# 2. Install wget to download malware, clear default Tomcat apps
RUN apt-get update && apt-get install -y wget curl && rm -rf /usr/local/tomcat/webapps/*

# 3. Copy the compiled vulnerable Spring application
COPY app/target/helloworld.war /usr/local/tomcat/webapps/ROOT.war

# 4. Create malware directory
RUN mkdir -p /tmp/malware && chmod 777 /tmp/malware

# 5. Inject the plain text file for the Secret Scanning demo
# Creating a specific directory makes it easy to point out during the demo
RUN mkdir -p /opt/secrets
COPY dummy-aws-creds.txt /opt/secrets/aws-credentials.txt

# 6. Expose default port
EXPOSE 8080

# 7. Define Entrypoint
ENTRYPOINT ["catalina.sh", "run"]