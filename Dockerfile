FROM alpine:latest

# Upgrade System and Install Dependencies
# Since Alpine comes with Busybox, wget is not needed
# since Busybox has its own version of wget.
# Also setup waterfall user.
RUN sed -i 's/v3.14/edge/g' /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk -U upgrade --no-cache \
    && apk add --no-cache openjdk17-jre-headless jq tini libstdc++

# Set Environment Variables
# Default Java args are from Aikar. https://mcflags.emc.gs
ENV \
    MIN_MEMORY="128M" \
    MAX_MEMORY="512M" \
    JAVA_ARGS=" \
        -XX:+UseG1GC \
        -XX:G1HeapRegionSize=4M \
        -XX:+UnlockExperimentalVMOptions \
        -XX:+ParallelRefProcEnabled \
        -XX:+AlwaysPreTouch \
        -Dusing.aikars.flags=https://mcflags.emc.gs \
        -Daikars.new.flags=true"

WORKDIR /advocatus

COPY Advocatus-Proxy/bootstrap/target/Advocatus.jar ./

COPY Advocatus-Proxy/module/cmd-alert/target/cmd_alert.jar ./modules/
COPY Advocatus-Proxy/module/cmd-find/target/cmd_find.jar ./modules/
COPY Advocatus-Proxy/module/cmd-list/target/cmd_list.jar ./modules/
COPY Advocatus-Proxy/module/cmd-send/target/cmd_send.jar ./modules/
COPY Advocatus-Proxy/module/cmd-server/target/cmd_server.jar ./modules/
COPY Advocatus-Proxy/module/reconnect-yaml/target/reconnect_yaml.jar ./modules/

ENTRYPOINT ["tini", "--"]
CMD ["java", "-server", "-Xms${MIN_MEMORY}", "-Xmx${MAX_MEMORY}", "${JAVA_ARGS}", "-jar", "advocatus.jar", "--nogui"]

VOLUME /advocatus
EXPOSE 25577/tcp