# BASE
FROM alpine:latest as base
LABEL maintainer="RoyalMind Development Team <support@royalmind.net>"
ENV TZ America/Mexico_City
RUN sed -i 's/v3.14/edge/g' /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk -U upgrade --no-cache \
    && apk add --no-cache openjdk17-jre-headless jq tini libstdc++ tzdata
WORKDIR /bungee
VOLUME /bungee
EXPOSE 25577

# BUILDING FINAL IMAGE
FROM base as final
ENV INIT_MEMORY "80M"
ENV MAX_MEMORY "512M"
COPY Advocatus-Proxy/bootstrap/target/Advocatus.jar ./Advocatus.jar
COPY Advocatus-Proxy/module/cmd-alert/target/cmd_alert.jar ./modules/cmd_alert.jar
COPY Advocatus-Proxy/module/cmd-find/target/cmd_find.jar ./modules/cmd_find.jar
COPY Advocatus-Proxy/module/cmd-list/target/cmd_list.jar ./modules/cmd_list.jar
COPY Advocatus-Proxy/module/cmd-send/target/cmd_send.jar ./modules/cmd_send.jar
COPY Advocatus-Proxy/module/cmd-server/target/cmd_server.jar ./modules/cmd_server.jar
COPY Advocatus-Proxy/module/reconnect-yaml/target/reconnect_yaml.jar ./modules/reconnect_yaml.jar
CMD echo "java -server -Xms\${MIN_MEMORY} -Xmx\${MAX_MEMORY} \${JAVA_ARGS} -jar advocatus.jar --nogui" > start.sh
RUN echo eula=true > eula.txt
ENTRYPOINT [ "tini", "--" ]
CMD [ "sh", "start.sh" ]
