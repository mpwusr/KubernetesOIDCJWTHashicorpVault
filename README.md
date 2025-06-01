# OIDC Token Generator for OpenShift API (Azure AD + HashiCorp Vault)

This script requests a JWT access token from Azure Active Directory using the OAuth2 `client_credentials` flow, securely retrieving the client credentials from **HashiCorp Vault**, and uses the token to authenticate against the OpenShift API.

---

## Dependencies

Install the following CLI tools:

```bash
brew install jq curl vault
export VAULT_ADDR=https://vault.mycompany.com
vault login <your-auth-method>
```
## Notes
* Token TTL is short (usually 3600 seconds), but can be re-issued as needed.
* Never hardcode your Azure CLIENT_SECRET or Vault token in the script.
* This approach supports full separation of secrets from code, ideal for automation.

## Device code flow – for interactive human login without client secret

Authorization code flow – for OAuth2 browser-based authentication

## Secret Setup (in HashiCorp Vault)
First, store your Azure AD credentials in Vault:

```
vault kv put secret/azure-ad/client \
  client_id="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
  client_secret="your-client-secret" \
  tenant_id="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```
This script assumes your Vault path is: secret/data/azure-ad/client.

## Testing and Usage
1. Make the script executable:
bash
```
chmod +x get_oidc_token_from_vault_and_call_openshift.sh
```
2. Run the script:
```
./get_oidc_token_from_vault_and_call_openshift.sh
```
✅ Expected Output
```
/apis/user.openshift.io/v1/users/~
```
And return output like:

```
{
  "kind": "User",
  "metadata": {
    "name": "john.doe@example.com"
  },
  ...
}
```
📎 Related References
Azure AD OAuth2 Client Credentials Flow

HashiCorp Vault KV Secrets Engine

OpenShift OAuth OIDC Integration

vbnet
Copy
Edit

