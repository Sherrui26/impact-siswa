# --- Build stage: compile the WAR with Maven ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Cache dependencies first for faster rebuilds
COPY pom.xml .
RUN mvn -q -e -B dependency:go-offline

COPY src ./src
RUN mvn -q -e -B clean package

# --- Runtime stage: Tomcat serving the WAR as ROOT ---
FROM tomcat:10.1-jre21
# Tomcat 10.x = Jakarta EE 9+, matches this project's jakarta.* imports

# Clear the default apps and deploy ours at the context root
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/impact-siswa.war /usr/local/tomcat/webapps/ROOT.war

# Render provides the port via $PORT; Tomcat listens on 8080 by default.
# We rewrite the connector port at startup so it binds to whatever Render assigns.
EXPOSE 8080
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
