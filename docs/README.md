### Overview

This Bash script uses [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) to retrieve and Base64 decode a Private Key stored as a secret in an Azure Key Vault.

The script will install the Private Key on an Azure DevOps Hosted Agent and set the proper permissions on the Private Key and the directory that contains the Private Key.

The script will add the Private Key to the authentication agent and add the IP Address of the Azure Virtual Machine it will use SSH to connect with in the *known_hosts* directory of the Azure DevOps Hosted Agent.

### Parameters

* [-k] KeyVaultName - Azure Key Vault name
* [-i] VMIPAddress - Virtual Machine IP Address
* [-n] KeyVault Secret Name - Name of the KeyVault Secret

## `aspnetcoreapp-deploy.sh`

This Bash script is executed in an Azure DevOps Release Pipeline Azure CLI Task.  When executed, it calls the `ssh-key-install.sh` script to install a Private Key on an Azure DevOps Hosted Agent.

Once the Private Key has been installed, the script will use [docker -H](https://docs.docker.com/v17.09/engine/reference/commandline/dockerd/) and SSH to connect to an Azure Virtual Machine and deploy the [mcr.microsoft.com/dotnet/core/samples:aspnetapp](https://hub.docker.com/_/microsoft-dotnet-core-samples/) image as a container.

### Parameters

* [-d] Docker Image Name - Docker Image Name
* [-v] Virtual Machine Username - Virtual Machine Username
* [-i] Virtual Machine IP Address - IP Address of Virtual Machine
* [-k] KeyVaultName - Azure Key Vault name
* [-d] Key Install Script Directory - Directory where the `ssh-key-install.sh` script resides
