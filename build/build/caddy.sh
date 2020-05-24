#!/bin/bash
# Created on 2020-05-25T08:54:10+1000, using template:caddy.sh.tmpl and json:gearbox.json

test -f /etc/gearbox/bin/colors.sh && . /etc/gearbox/bin/colors.sh

c_ok "Started."

c_ok "Installing packages."
APKBIN="$(which apk)"
if [ "${APKBIN}" != "" ]
then
	if [ -f /etc/gearbox/build/caddy.apks ]
	then
		APKS="$(cat /etc/gearbox/build/caddy.apks)"
		${APKBIN} update && ${APKBIN} add --no-cache --virtual gearbox ${APKS}; checkExit
	fi
fi

APTBIN="$(which apt-get)"
if [ "${APTBIN}" != "" ]
then
	if [ -f /etc/gearbox/build/caddy.apt ]
	then
		DEBS="$(cat /etc/gearbox/build/caddy.apt)"
		${APTBIN} update && ${APTBIN} install ${DEBS}; checkExit
	fi
fi


if [ -f /etc/gearbox/build/caddy.env ]
then
	. /etc/gearbox/build/caddy.env
fi

if [ ! -d /usr/local/bin ]
then
	mkdir -p /usr/local/bin; checkExit
fi


c_ok "Generate installed file list"
c_ok "####################"
apk info -v -R gearbox | sed 's/gearbox://' | xargs apk info -L | awk '/bin\//{print"/"$1}'
c_ok "####################"

# https://github.com/caddyserver/caddy/releases/download/v2.0.0/caddy_2.0.0_linux_amd64.tar.gz
# https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_amd64.tar.gz
# https://github.com/caddyserver/caddy/releases/download/v0.11.5/caddy_v0.11.5_linux_amd64.tar.gz
# https://github.com/caddyserver/caddy/releases/download/v0.10.14/caddy_v0.10.14_linux_amd64.tar.gz
# https://github.com/caddyserver/caddy/releases/download/v0.9.5/caddy_linux_amd64.tar.gz
# https://github.com/caddyserver/caddy/releases/download/v0.8.3/caddy_linux_amd64.tar.gz
# https://github.com/caddyserver/caddy/releases/download/v0.7.6/caddy_linux_amd64.tar.gz
# https://github.com/caddyserver/caddy/releases/download/v0.6.0/caddy_linux_amd64.tar.gz
# https://github.com/caddyserver/caddy/releases/download/v0.5.1/caddy_linux_amd64.tar.gz
# curl --silent --show-error --fail --location --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - ${URL}


cd /usr/local/bin
case ${GB_VERSION} in
	"2.0.0")
		URL="https://github.com/caddyserver/caddy/releases/download/v${GB_VERSION}/caddy_${GB_VERSION}_linux_amd64.tar.gz"
		;;

	"1.0.4")
		URL="https://github.com/caddyserver/caddy/releases/download/v${GB_VERSION}/caddy_${GB_VERSION}_linux_amd64.tar.gz"
		;;

	"0.10.14"|"0.11.5")
		URL="https://github.com/caddyserver/caddy/releases/download/v${GB_VERSION}/caddy_${GB_VERSION}_linux_amd64.tar.gz"
		;;

	"0.9.5"|"0.8.3"|"0.7.6"|"0.6.0"|"0.5.1")
		URL="https://github.com/caddyserver/caddy/releases/download/v${GB_VERSION}/caddy_linux_amd64.tar.gz"
		;;

	*)
		c_err "Unknown version within build.sh"
		;;
esac


c_ok "Extracting Caddy release."
wget -qO- --no-check-certificate ${URL} | tar zxvf - caddy; checkExit
if [ ! -f /usr/local/bin/caddy ]
then
	c_err "Failed to find /usr/local/bin/caddy"
else
	chmod a+x /usr/local/bin/caddy; checkExit
	/usr/local/bin/caddy -version; checkExit
fi

/etc/gearbox/bin/JsonToConfig -json /usr/local/etc/caddy.conf.json -template /usr/local/etc/caddy.conf.tmpl -out /usr/local/etc/caddy.conf


c_ok "Finished."
