#!/bin/sh

# Generating client certificates
CA_CERT="/etc/ocserv/certs/ca-cert.pem"
CA_KEY="/etc/ocserv/certs/ca-key.pem"


USER="$1"
USER_TMPL="/etc/ocserv/certs/$USER.tmpl"
USER_KEY="/etc/ocserv/certs/$USER-key.pem"
USER_CERT="/etc/ocserv/certs/$USER-cert.pem"
USER_P12="/etc/ocserv/certs/$USER.p12"

# User Template
cat << _EOF_ > $USER_TMPL
cn = "$USER"
expiration_days = 3650
signing_key
tls_www_client
_EOF_

# User Private Key
certtool --generate-privkey --outfile $USER_KEY

# User Certificate
certtool --generate-certificate --load-privkey $USER_KEY --load-ca-certificate $CA_CERT --load-ca-privkey $CA_KEY --template $USER_TMPL --outfile $USER_CERT

# Export User Certificate
echo "==> Please enter key name and password manually."
certtool --to-p12 --pkcs-cipher 3des-pkcs12 --load-privkey $USER_KEY --load-certificate $USER_CERT --outfile $USER_P12 --outder
