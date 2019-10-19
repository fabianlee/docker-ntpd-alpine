FROM alpine:latest

# latest certs
RUN apk add ca-certificates && update-ca-certificates

# timezone support
ENV TZ=UTC
RUN apk add --update tzdata &&\
    cp /usr/share/zoneinfo/${TZ} /etc/localtime &&\
    echo $TZ > /etc/timezone

# install openntp
RUN apk add --no-cache openntpd

# use custom ntpd config file
COPY assets/ntpd.conf /etc/ntpd.conf

# ntp port exposed locally, still needs to be published
EXPOSE 123/udp

# test container health, returns 0=success even if not all peers avail
HEALTHCHECK CMD ntpctl -s status || exit 1

# start ntpd -v verbose, -d foreground to stdout, -s set time at startup
ENTRYPOINT [ "/usr/sbin/ntpd", "-v", "-d", "-s" ]

# if debugging
#ENTRYPOINT [ "/bin/ash" ]
