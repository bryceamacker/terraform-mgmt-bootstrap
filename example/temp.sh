#!/bin/bash

export $(egrep -v '^#' "../.env" | xargs)

echo -e "\n\e[34m»»» ✨ \e[96mTerraform init\e[0m..."
terraform init -input=false -backend=true -reconfigure \
  -backend-config="resource_group_name=$TF_VAR_mgmt_res_group" \
  -backend-config="storage_account_name=$TF_VAR_state_storage" \
  -backend-config="container_name=$TF_VAR_state_container" \
  -backend-config="key=demo"
