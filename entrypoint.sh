#!/bin/sh

# Generating the CA
CA_TMPL="/etc/ocserv/certs/ca.tmpl"
CA_KEY="/etc/ocserv/certs/ca-key.pem"
CA_CERT="/etc/ocserv/certs/ca-cert.pem"

[ -z "$CA_CN" ] && CA_CN="VPN CA"
[ -z "$CA_ORG" ] && CA_ORG="Big Corp"
[ -z "$CA_DAYS" ] && CA_DAYS="-1"

[ -f "$CA_TMPL" ] || cat << _EOF_ > $CA_TMPL
cn = "$CA_CN"
organization = "$CA_ORG"
serial = 1
expiration_days = "$CA_DAYS"
ca
signing_key
cert_signing_key
crl_signing_key
_EOF_

[ -f "$CA_KEY" ] || certtool --generate-privkey --outfile $CA_KEY
[ -f "$CA_CERT" ] || certtool --generate-self-signed --load-privkey $CA_KEY --template $CA_TMPL --outfile $CA_CERT

# Generating server certificate
SRV_TMPL="/etc/ocserv/certs/server.tmpl"
SRV_KEY="/etc/ocserv/certs/server-key.pem"
SRV_CERT="/etc/ocserv/certs/server-cert.pem"

[ -z "$SRV_CN" ] && SRV_CN="VPN server"
[ -z "$SRV_DNS" ] && SRV_DNS="www.example.com"
[ -z "$SRV_ORG" ] && SRV_ORG="MyCompany"
[ -z "$SRV_DAYS" ] && SRV_DAYS="-1"

[ -f "$SRV_TMPL" ] || cat << _EOF_ > $SRV_TMPL
cn = "$SRV_CN"
dns_name = "$SRV_DNS"
organization = "$SRV_ORG"
expiration_days = "$SRV_DAYS"
signing_key
encryption_key
tls_www_server
_EOF_

[ -f "$SRV_KEY" ] || certtool --generate-privkey --outfile $SRV_KEY
[ -f "$SRV_CERT" ] || certtool --generate-certificate --load-privkey $SRV_KEY --load-ca-certificate $CA_CERT --load-ca-privkey $CA_KEY --template $SRV_TMPL --outfile $SRV_CERT

# Create a test user
if [ -z "$NO_TEST_USER" ] && [ ! -f /etc/ocserv/ocpasswd ]; then
  echo "Create test user 'test' with password 'test'"
  echo 'test:*:$5$DktJBFKobxCFd7wN$sn.bVw8ytyAaNamO.CvgBvkzDiFR6DaHdUzcif52KK7' > /etc/ocserv/ocpasswd
fi

# Open ipv4 ip forward
sysctl -w net.ipv4.ip_forward=1

# Enable NAT forwarding
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Enable TUN device
if [ ! -e /dev/net/tun ]; then
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
  chmod 600 /dev/net/tun
fi

# Run OpennConnect Server
OCSERV_CONF="/etc/supervisor/conf.d/ocserv.conf"

[ -f $OCSERV_CONF ] || cat << _EOF_ > $OCSERV_CONF
[program:ocserv]
command=ocserv -c /etc/ocserv/ocserv.conf -f -d 1
autostart=true
autorestart=true
stderr_logfile=/var/log/ocserv_error.log
stdout_logfile=/var/log/ocserv.log
priority=5
_EOF_

exec "$@"
