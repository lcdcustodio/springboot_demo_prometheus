FROM openjdk:8-alpine

ARG JAR_FILE=target/*.jar

RUN mkdir -p /app
WORKDIR /app
ENV JAVA_OPTS = ""

COPY ${JAR_FILE} /app/app.war

ENTRYPOINT  ["java", "-jar", "/app/app.war", "${JAVA_OPTS}"]
