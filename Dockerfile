FROM node:22-alpine AS frontend-build
WORKDIR /build/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

FROM maven:3.9-eclipse-temurin-21-alpine AS application-build
WORKDIR /build
COPY pom.xml ./
RUN mvn -B -Dmaven.test.skip=true -Dcheckstyle.skip dependency:go-offline
COPY src ./src
COPY --from=frontend-build /build/src/main/resources/static ./src/main/resources/static
RUN mvn -B -Dmaven.test.skip=true -Dcheckstyle.skip package

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S application && adduser -S application -G application
COPY --from=application-build --chown=application:application /build/target/quiz-1.0.0.jar ./application.jar
USER application
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/application.jar"]
