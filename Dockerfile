FROM ubuntu:22.04 as BUILD
WORKDIR /app
RUN apt update && apt install -y openjdk-17-jdk wget tar \
    && wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz \
    && tar -xvf apache-maven-3.9.11-bin.tar.gz \
    && mv apache-maven-3.9.11 /opt/maven
ENV M2_HOME=/opt/maven
ENV PATH="$PATH:$M2_HOME/bin"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$PATH:$JAVA_HOME/bin"
COPY . .
RUN mvn clean package -DskipTests


FROM bitnami/tomcat
COPY --from=BUILD /app/webapp/target/*.war   /opt/bitnami/tomcat/webapps
EXPOSE 8080
CMD ["catalina.sh", "run"]
