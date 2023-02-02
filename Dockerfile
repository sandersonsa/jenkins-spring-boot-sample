FROM registry.access.redhat.com/ubi8/openjdk-11-runtime@sha256:88599a17f9d463f8b2a2d9a03f6216d20e25370174b0b9556351c986ee0aa9fa

ENV JAR_FILE=target/demo-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} /app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar","-Djava.net.preferIPv4Stack=true -Dspring.cloud.kubernetes.enabled=false"]

