FROM openjdk:12-ea-23-jdk-oraclelinux7 as build-env

WORKDIR /source
ADD HelloWorld.java /source
RUN javac -d /build HelloWorld.java
RUN ls .


#https://mjg123.github.io/2018/11/05/alpine-jdk11-images.html
FROM alpine:latest as jre

# This is the latest Portola distribution at the time of writing
ADD https://download.java.net/java/early_access/alpine/18/binaries/openjdk-12-ea+18_linux-x64-musl_bin.tar.gz /stage/jdk
RUN mkdir -p /opt/jdk
RUN tar -xvf /stage/jdk -C /opt/jdk
RUN ls -la /opt/jdk/jdk-12
RUN ["/opt/jdk/jdk-12/bin/jlink", "--compress=2", \
     "--module-path", "/opt/jdk/jdk-12/jmods", \
     "--add-modules", "java.base", \
     "--output", "/jlinked"]


FROM alpine:3.8
WORKDIR /app
COPY --from=jre /jlinked /opt/jdk/
COPY --from=build-env /build/HelloWorld.class /app
CMD ["/opt/jdk/bin/java", "HelloWorld"]
