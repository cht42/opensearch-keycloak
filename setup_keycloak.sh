#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

export $(grep -v '^#' .env | xargs)

echo -n "Getting admin access token..."
ADMIN_TOKEN=$(curl -ks -X POST \
"$KEYCLOAK_URL/auth/realms/master/protocol/openid-connect/token" \
-H "Content-Type: application/x-www-form-urlencoded" \
-d "username=$KEYCLOAK_ADMIN_LOGIN" \
-d "password=$KEYCLOAK_ADMIN_PASSWORD" \
-d 'grant_type=password' \
-d 'client_id=admin-cli' | jq -r '.access_token')
if [ $ADMIN_TOKEN == "null" ]; then
    echo -e "${RED} \u2717 Could not get admin token ${NC}"
    exit 1
else
    echo -e "${GREEN} \xE2\x9C\x94 ${NC}"
fi

echo -n "Setting access token lifespan to 1 hour..."
response=$(curl -iks -X PUT "$KEYCLOAK_URL/auth/admin/realms/master" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '
{
  "accessTokenLifespan": 3600
}' | grep HTTP | awk '{print $2}')
if [ $response == "204" ]; then
    echo -e "${GREEN} \u2713 ${NC}"
else
    echo -e "${RED} \u2717 ${NC}"
fi

echo -n "Creating $KEYCLOAK_DASHBOARDS_CLIENT_ID client"
response=$(curl -kis -X POST "$KEYCLOAK_URL/auth/admin/realms/master/clients" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '
{
  "clientId": "'$KEYCLOAK_DASHBOARDS_CLIENT_ID'",
  "rootUrl": "https://localhost:5601",
  "redirectUris": ["https://localhost:5601/*"],
  "publicClient": false,
  "secret": "'$KEYCLOAK_DASHBOARDS_CLIENT_SECRET'"
}'| grep HTTP | awk '{print $2}')
if [ $response == "201" ]; then
    echo -e "${GREEN} \u2713 ${NC}"
else
    echo -e "${RED} \u2717 ${NC}"
fi


