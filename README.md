# Overview

### ⚠ Warning! "Here Be Dragons" 🐲

**In general there is no need to edit any files in this directory, if you aren't sure, don't change anything**

This Terraform provisions the one-time management resources which are shared and common to the process.  
It is intended to be run once or infrequently, and run manually from an administrators local machine or Azure Cloud Shell. There is no automation or CI/CD

# Manual One Time Setup Tasks

Complete automation and "zero touch" bootstraping into a new tenant was deemed out of scope or too problematic to fully automate. There are several aspects which are required to be manually created. **_The following list is by no means exhaustive and this process has not been verified end to end_**

- Azure DevOps organization & project
- Azure subscriptions: **sub-management**, **broadside-subscription-test**, **subscription-staging**, **sub-test-tenant**
- Hierarchy of management groups: **mg-stable**, **mg-test**. Under **mg-stable**: the following groups **mg-dev** **mg-staging** and **mg-sub-test**
- Variable group in the Azure DevOps project named **cicd-variable-group**, this should be linked to Key Vault using the **keyvault-access** service connection
- Populate the **sub-management** Key Vault (name defined in `shared_keyvault_name` variable) with the [secrets detailed at the bottom of the page](#Key-Vault-Secret-List)
- An Azure service principal named **deploy-automation** which all the pipelines will use to the run the Terraform and hold state. Once created it's credentials need to be set in the following secrets: `backend-client-id`, `backend-client-secret`,`backend-client-subscriptionid` & `backend-client-tenantid`
- An AD group called **automation-accounts**, and the **deploy-automation** service principal added as member
- The **automation-accounts** group assigned the following roles on the tenant root management group: `Management Group Contributor` and `Owner`
- The **automation-accounts** group assigned the following roles on the management subscription: `Storage Blob Data Contributor` and `Contributor`

# Management Resources Deployment

## Pre-reqs

- Bash
- Terraform 0.13.0+
- Authenticated connection to Azure, with account set to **sub-management** subscription. Unlike the rest of the Terraform, this was intended to be run interactively
- An Azure DevOps PAT token (full scope) for the relevant Azure DevOps organization

## Steps

- Copy `.env.sample` to `.env` and set values for all variables; `BACKEND_RESGRP`, `BACKEND_STORAGE_ACCOUNT`, `BACKEND_CONTAINER` & `AZDO_PAT`
- From bash run `./deploy.sh`

# Resources

The Terraform creates & configures the following:

- Resource Group
- Storage Account for holding Terraform state
- Azure Container Registry for holding the agent tools image
- KeyVault for holding credentials and secrets used by Azure DevOps Pipelines
- Service Principal, with IAM role assignment to access the KeyVault "Key Vault Reader (preview)"
- KeyVault access policy for above Service Principal to allow it to get & list secrets
- Azure DevOps service connection called "keyvault-access" to allow variable groups to be linked to the KeyVault

# State Chicken & Egg Problem

As the backend state is held in the storage account created by the Terraform itself, this results in a chicken and egg problem.

The very first time this is to be deployed in an new tenant, a one time bootstrap script should be run:

- Copy `.env.sample` to `.env` and set values for all variables; `BACKEND_RESGRP`, `BACKEND_STORAGE_ACCOUNT`, `BACKEND_CONTAINER` & `AZDO_PAT`
- From bash run `./bootstrap.sh`
