# Overview

The bash scripts in this repository can be used in an Azure DevOps Pipeline to install a Private Key on a Azure DevOps Hosted Agent & use Docker to SSH into an Azure Virtual Machine to start a Docker Container.

## Technology

- azure-cli
- bash
- Docker

## ```aspnetcoreapp-deploy.sh```

This bash script is executed in an Azure DevOps Release Pipeline Azure CLI Task.  When executed, it calls the ```ssh-key-install.sh``` script to install a private Key on an Azure DevOps Hosted Agent.

Once the private Key has been installed, the script will use [docker -H](https://docs.docker.com/v17.09/engine/reference/commandline/dockerd/) and SSH to connect to an Azure Virtual Machine and deploy the [mcr.microsoft.com/dotnet/core/samples:aspnetapp](https://hub.docker.com/_/microsoft-dotnet-core-samples/) image as a container.

### Parameters

- [-d] Docker Image Name - Docker Image Name
- [-v] Virtual Machine Username - Virtual Machine Username
- [-i] Virtual Machine IP Address - IP Address of Virtual Machine
- [-k] KeyVaultName - Azure Key Vault name
- [-d] Key Install Script Directory - Directory where the `ssh-key-install.sh` script resides

## ```ssh-key-install.sh```

This bash script is called by the ```aspnetcoreapp-deploy.sh``` script & is responsible for retrieving a private key from Azure KeyVault & installing the private key on the Azure DevOps Hosted Agent.  The script also adds the Azure Virtual Machine's IP address to the Azure DevOps Hosted Agent's *known_hosts* file.

### Parameters

- [-k] KeyVaultName - Azure Key Vault name
- [-i] VMIPAddress - Virtual Machine IP Address
- [-n] KeyVault Secret Name - Name of the KeyVault Secret
