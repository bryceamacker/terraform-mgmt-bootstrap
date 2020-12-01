# Terraform Bootstrap for Shared Management & CI/CD

This repo holds a set of reusable generic scripts and Terraform configuration to "bootstrap" a project in order to be able to start using Terraform with Azure. This paves the way for the set up of Azure DevOps Pipelines to deploy further resources. This aligns with the common "hub & spoke" style of Azure architecture. where one shared set of management resources are used to support the deployment and management of one or more spokes through automated CI/CD pipelines. These spokes could be separate subscriptions or simply multiple environments in different resource groups for hosting simultaneous instances of an app.

Note. There is no dependency or relation to the [hub & spoke network topology](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology)

There's four main outcomes of this repo:

- Bootstrap of backend state in Azure Storage for all Terraform to use.
- Deployment (and redeployment) set of shared, management resources.
- Creation of service principals with role assignments in Azure AD.
- Initial configuration of Azure DevOps

All of the scripts in this repo are intended to be run manually and infrequently, and called from an administrators local machine or Azure Cloud Shell. There is no automation or CI/CD, this is by design - the purpose of this repo is to allow further CI/CD to happen.

## Pre-reqs

- Bash
- Terraform 0.13+
- Azure CLI
- Authenticated connection to Azure, using Azure CLI
- Azure DevOps organization and project
- An Azure DevOps PAT token (full scope) for the relevant Azure DevOps organization

Each of the two mains scripts ('bootstrap' and 'deploy') checks most of these pre-reqs before running

## Configuration

Before running any of the scripts, the configuration and input variables need to be set. This is done in an `.env` file, and this file is read and parsed by scripts

Note. `.tfvars` file is not used, this is intentional. The dotenv format is easier to parse, meaning we can use the values for bash scripts and other purposes

Copy `.env.sample` to `.env` and set values for all variables:

- `TF_VAR_state_storage` - The name of the storage account to hold Terraform state.
- `TF_VAR_mgmt_res_group` - The shared resource group for all hub resources, including the storage account.
- `TF_VAR_state_container` - Name of the blob container to hold Terraform state (default: `tfstate`).
- `TF_VAR_prefix` - A prefix added to all resources, pick your project name or other prefix to give the resources unique names.
- `TF_VAR_region` - Azure region to deploy all resources into.
- `TF_VAR_azdo_org_url` - URL of Azure DevOps org to use, e.g. https<span>://dev.azure.com/foobar</span>
- `TF_VAR_azdo_project_name` - Name of the Azure DevOps project in the above org.
- `TF_VAR_azdo_pat` - [Azure DevOps access token](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page) with rights to create variable groups and service connections.

# Bootstrap of Backend State

As a principal we want all our resources defined in Terraform, including the storage account using by Terraform to hold backend state. This results in a chicken and egg problem.

To solve this a bootstrap script is used which creates the initial storage account and resource group using the Azure CLI. Then Terraform is initialized using this storage account as a backend, and the storage account imported into state

- From bash run `./bootstrap.sh`

This script should never need running a second time even if the other management resources are modified

# Management Resource Deployment

The deployment of the rest of the shared management resources is done via Terraform, and the various .tf files in the root of this repo.

- From bash run `./deploy.sh`

This Terraform creates & configures the following:

- Resource Group (also in bootstrap).
- Storage Account for holding Terraform state (also in bootstrap).
- Azure Container Registry.
- Azure Log Analytics.
- KeyVault for holding credentials and secrets used by Azure DevOps Pipelines.
- Service Principal, with IAM role assignment to access the KeyVault "Key Vault Reader (preview)".
- A second Service Principal (to be used for pipelines), with IAM role "Contributor" at the subscription level.
- KeyVault access policy for above Service Principal to allow it to get & list secrets.
- KeyVault access policy for the current user to be able to manage secrets.
- Populates KeyVault with secrets, holding the credential details for the pipeline service principal

# Azure DevOps

The deployment Terraform also sets up some initial configuration in Azure DevOps namely service connection called "keyvault-access" to allow variable groups to be linked to the KeyVault.

The creation of a Azure DevOps variable group linked to KeyVault can not be done via Terraform or the Azure CLI. A work-around using cURL and REST API has been created in `azdo-var-group.sh` running this script will create a variable group called `shared-secrets` in the project and populate it with four variables

- `pipeline-sp-clientid`
- `pipeline-sp-secret`
- `azure-tenant-id`
- `azure-sub-id`

These variables can be used in subsequent Azure DevOps pipelines.

# Next Steps

This repo is intended to lay the ground work for Azure DevOps pipelines to be set up to deploy further resources. The shared variable group is a key part of enabling this, but the configuration of those pipelines is something deeply project specific, so is not covered here.

An example pipeline is given in the `azdo/` directory, showing how to run a pipeline using the shared state and the service principal that has been setup using secure variables

If you are using a mono-repo, the whole of this repo can be dropped in as a sub-folder, in order to keep the Terraform separate from any Terraform you wish to use in your other "spoke" pipelines
