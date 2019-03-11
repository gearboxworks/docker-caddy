FROM alpine:3.5

MAINTAINER Gearbox Team <team@gearbox.works>

RUN set -x \
  && apk add --no-cache \
  curl \
  && curl --silent --show-error --fail --location \
    --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
    "https://caddyserver.com/download/linux/amd64" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
  && chmod 0755 /usr/bin/caddy \
  && /usr/bin/caddy -version

EXPOSE 80 443

COPY files /

ENTRYPOINT ["/usr/bin/caddy"]
CMD [ "-conf", "/etc/caddy/caddy.conf" ]