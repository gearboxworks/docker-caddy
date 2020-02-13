#!/bin/bash

# See gearboxworks/gearbox-base for details.
test -f /build/include-me.sh && . /build/include-me.sh

c_ok "Started."

c_ok "Installing packages."
APKS="$(cat /build/build-caddy.apks)"
if [ "${APKS}" != "" ]
then
	apk update && apk add --no-cache ${APKS}; checkExit
fi

if [ -f /build/build-caddy.env ]
then
	. /build/build-caddy.env
fi

if [ ! -d /usr/local/bin ]
then
	mkdir -p /usr/local/bin; checkExit
fi

# curl --silent --show-error --fail --location --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - ${URL}
cd /usr/local/bin
wget -qO- --no-check-certificate ${URL} | tar zxvf - caddy; checkExit

if [ ! -f /usr/local/bin/caddy ]
then
	c_err "Failed to find /usr/local/bin/caddy"
else
	chmod a+x /usr/local/bin/caddy; checkExit
	/usr/local/bin/caddy -version; checkExit
fi

c_ok "Finished."
