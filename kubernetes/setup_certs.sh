#!/bin/bash

mkdir -p certs/{ca,keycloak,dashboards,opensearch-master}


# Choose an appropriate DN
CERTS_DN="/C=UN/ST=UN/L=UN/O=UN"

# Generate root CA (ignore if you already have one)
openssl genrsa -out certs/ca/ca.key 2048
openssl req -new -x509 -sha256 -days 1095 -subj "$CERTS_DN/CN=CA" -key certs/ca/ca.key -out certs/ca/ca.pem

# Generate Keycloak certificate, signed by your CA
openssl genrsa -out certs/keycloak/keycloak-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/keycloak/keycloak-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/keycloak/keycloak.key
openssl req -new -subj "$CERTS_DN/CN=keycloak" -key certs/keycloak/keycloak.key -out certs/keycloak/keycloak.csr
openssl x509 -req -extfile <(printf "subjectAltName=DNS:keycloak,IP:127.0.0.1,IP:172.17.0.1") -in certs/keycloak/keycloak.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/keycloak/keycloak.pem
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

# Opensearch master node
openssl genrsa -out certs/opensearch-master/opensearch-master-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/opensearch-master/opensearch-master-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/opensearch-master/opensearch-master.key
openssl req -new -subj "$CERTS_DN/CN=opensearch-master" -key certs/opensearch-master/opensearch-master.key -out certs/opensearch-master/opensearch-master.csr
openssl x509 -req -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:opensearch-master") -in certs/opensearch-master/opensearch-master.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/opensearch-master/opensearch-master.pem

# OpenSearch Dashboards
openssl genrsa -out certs/dashboards/dashboards-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/dashboards/dashboards-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/dashboards/dashboards.key
openssl req -new -subj "$CERTS_DN/CN=dashboards" -key certs/dashboards/dashboards.key -out certs/dashboards/dashboards.csr
openssl x509 -req -in certs/dashboards/dashboards.csr -CA certs/ca/ca.pem -CAkey certs/ca/ca.key -CAcreateserial -sha256 -out certs/dashboards/dashboards.pem

# Cleanup
rm certs/ca/admin-temp.key certs/ca/admin.csr
rm certs/opensearch-master/opensearch-master-temp.key certs/opensearch-master/opensearch-master.csr
rm certs/dashboards/dashboards-temp.key certs/dashboards/dashboards.csr

# Adjusting permissions
chmod 700 certs/{ca,dashboards,opensearch-master}
chmod 600 certs/{ca/*,dashboards/*,opensearch-master/*}
