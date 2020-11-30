#!/bin/bash

VARGROUP_NAME="shared-secrets"

echo -e "\n\e[34m╔══════════════════════════════════════════╗"
echo -e "║\e[33m        Configure Azure DevOps 🧶\e[34m         ║"
echo -e "║\e[32m  Create KeyVault linked variable group \e[34m  ║"
echo -e "╚══════════════════════════════════════════╝"

# Load env vars from .env file
if [ ! -f ".env" ]; then
  echo -e "\e[31m»»» 💥 Unable to find .env file, please create file and try again!"
  exit
else
  echo -e "\n\e[34m»»» 🧩 \e[96mLoading environmental variables\e[0m..."
  export $(egrep -v '^#' ".env" | xargs)
fi

# Get project id from project name in AzDo
echo -e "\e[34m»»» 🔍 \e[96mGetting project ID from Azure DevOps\e[0m..."
PROJ_ID=$(curl -Ss -X GET "$TF_VAR_azdo_org_url/_apis/projects?api-version=6.1-preview.4" \
--user user:$TF_VAR_azdo_pat \
| jq -r ".value[] | select (.name == \"$TF_VAR_azdo_project_name\") | .id")
echo -e "\e[34m»»» 🔍 \e[96mGot ID: $PROJ_ID\e[0m"

# Get service connection id created in 
SERVICE_CONN_ID=$(terraform output keyvault_access_connection_id)
KV_NAME=$(terraform output keyvault_name)
echo -e "\e[34m»»» 📌 \e[96mService connection ID: $SERVICE_CONN_ID\e[0m"
echo -e "\e[34m»»» 🔑 \e[96mKeyVault name: $KV_NAME\e[0m"

# Call REST API to create the variable group
# Note. 'pipeline-sp-secret' must match the name of the secret created in main.tf
curl -Ss -X POST "$TF_VAR_azdo_org_url/$TF_VAR_azdo_project_name/_apis/distributedtask/variablegroups?api-version=6.1-preview.2" \
--user user:$TF_VAR_azdo_pat -H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
  "name": "$VARGROUP_NAME",
  "providerData": null,
  "type": "AzureKeyVault",
  "variables": { 
    "pipeline-sp-secret": { 
      "isSecret": true, 
      "value": null,
      "enabled": true
    },
    "pipeline-sp-clientid": { 
      "isSecret": true, 
      "value": null,
      "enabled": true
    },
    "azure-tenant-id": { 
      "isSecret": true, 
      "value": null,
      "enabled": true
    },
    "azure-sub-id": { 
      "isSecret": true, 
      "value": null,
      "enabled": true
    }         
  },
  "providerData": {
    "serviceEndpointId": "$SERVICE_CONN_ID",
    "vault": "$KV_NAME"
  },
  "variableGroupProjectReferences": [
    {
      "name": "$VARGROUP_NAME",
      "projectReference": {
        "id": "$PROJ_ID"
      }
    }
  ]
}
EOF
