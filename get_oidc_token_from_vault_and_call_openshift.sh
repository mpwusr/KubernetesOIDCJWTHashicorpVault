#!/bin/bash

# Vault config
VAULT_ADDR="https://vault.mycompany.com"
VAULT_PATH="secret/data/azure-ad/client"
VAULT_TOKEN="${VAULT_TOKEN:-$(cat ~/.vault-token)}"

# OpenShift API endpoint
OPENSHIFT_API="https://api.openshift.example.com:6443"

# Fetch Azure app credentials from Vault
echo "🔐 Fetching Azure AD credentials from HashiCorp Vault..."

VAULT_SECRET=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
  "$VAULT_ADDR/v1/$VAULT_PATH")

CLIENT_ID=$(echo "$VAULT_SECRET" | jq -r '.data.data.client_id')
CLIENT_SECRET=$(echo "$VAULT_SECRET" | jq -r '.data.data.client_secret')
TENANT_ID=$(echo "$VAULT_SECRET" | jq -r '.data.data.tenant_id')

if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" || -z "$TENANT_ID" ]]; then
  echo "Missing data from Vault. Check path: $VAULT_PATH"
  exit 1
fi

# Get access token from Azure AD
echo "Requesting access token from Azure AD..."

TOKEN_URL="https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token"
SCOPE="openid profile email"

TOKEN_RESPONSE=$(curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "grant_type=client_credentials" \
  -d "scope=$SCOPE")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')

if [[ "$ACCESS_TOKEN" == "null" || -z "$ACCESS_TOKEN" ]]; then
  echo "Failed to retrieve Azure AD token"
  echo "$TOKEN_RESPONSE"
  exit 1
fi

echo "Access Token retrieved"

# Call OpenShift API with the token
echo "Calling OpenShift API using JWT..."

API_RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Accept: application/json" \
  "$OPENSHIFT_API/apis/user.openshift.io/v1/users/~")

echo "👤 OpenShift User Info:"
echo "$API_RESPONSE" | jq
