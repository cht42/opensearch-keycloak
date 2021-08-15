#!/bin/bash

mkdir -p certs/{ca,keycloak,os-dashboards,os01,os02,os03}


# Choose an appropriate DN
CERTS_DN="/C=UN/ST=UN/L=UN/O=UN"

# Generate root CA (ignore if you already have one)
openssl genrsa -out certs/ca/ca.key 2048
openssl req -new -x509 -sha256 -days 1095 -subj "$CERTS_DN/CN=CA" -key certs/ca/ca.key -out certs/ca/ca.pem

# Generate Keycloak certificate, signed by your CA
openssl genrsa -out certs/keycloak/keycloak-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/keycloak/keycloak-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/keycloak/keycloak.key
openssl req -new -subj "$CERTS_DN/CN=keycloak" -key certs/keycloak/keycloak.key -out certs/keycloak/keycloak.csr
openssl x509 -req -extfile <(printf "subjectAltName=IP:127.0.0.1,IP:172.17.0.1") -in certs/keycloak/keycloak.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/keycloak/keycloak.pem
rm certs/keycloak/keycloak-temp.key certs/keycloak/keycloak.csr

# Configuring filenames and rights for Keycloak container
cp certs/keycloak/keycloak.key certs/keycloak/tls.key
cp certs/keycloak/keycloak.pem certs/keycloak/tls.crt
chmod 655 certs/keycloak/tls.crt certs/keycloak/tls.key


# Admin
openssl genrsa -out certs/ca/admin-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/ca/admin-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/ca/admin.key
openssl req -new -subj "$CERTS_DN/CN=ADMIN" -key certs/ca/admin.key -out certs/ca/admin.csr
openssl x509 -req -in certs/ca/admin.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/ca/admin.pem

# Node 1
openssl genrsa -out certs/os01/os01-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/os01/os01-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/os01/os01.key
openssl req -new -subj "$CERTS_DN/CN=os01" -key certs/os01/os01.key -out certs/os01/os01.csr
openssl x509 -req -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:os01") -in certs/os01/os01.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/os01/os01.pem

# Node 2
openssl genrsa -out certs/os02/os02-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/os02/os02-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/os02/os02.key
openssl req -new -subj "$CERTS_DN/CN=os02" -key certs/os02/os02.key -out certs/os02/os02.csr
openssl x509 -req -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:os02") -in certs/os02/os02.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/os02/os02.pem

# Node 3
openssl genrsa -out certs/os03/os03-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/os03/os03-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/os03/os03.key
openssl req -new -subj "$CERTS_DN/CN=os03" -key certs/os03/os03.key -out certs/os03/os03.csr
openssl x509 -req -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:os03") -in certs/os03/os03.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/os03/os03.pem

# OpenSearch Dashboards
openssl genrsa -out certs/os-dashboards/os-dashboards-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/os-dashboards/os-dashboards-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/os-dashboards/os-dashboards.key
openssl req -new -subj "$CERTS_DN/CN=os-dashboards" -key certs/os-dashboards/os-dashboards.key -out certs/os-dashboards/os-dashboards.csr
openssl x509 -req -in certs/os-dashboards/os-dashboards.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/os-dashboards/os-dashboards.pem

# Cleanup
rm certs/ca/admin-temp.key certs/ca/admin.csr
rm certs/os01/os01-temp.key certs/os01/os01.csr
rm certs/os02/os02-temp.key certs/os02/os02.csr
rm certs/os03/os03-temp.key certs/os03/os03.csr
rm certs/os-dashboards/os-dashboards-temp.key certs/os-dashboards/os-dashboards.csr

# Adjusting permissions
chmod 700 certs/{ca,os-dashboards,os01,os02,os03}
chmod 600 certs/{ca/*,os-dashboards/*,os01/*,os02/*,os03/*}
