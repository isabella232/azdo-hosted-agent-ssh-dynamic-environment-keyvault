#!/bin/bash -eu

################################################################################################################################
#- Purpose: Script is used to install a SSH Private Key onto the Azure DevOps Pipeline Agent
#- Parameters are:
#- [-k] KeyVaultName - Azure Key Vault name
#- [-i] VMIPAddress - Virtual Machine IP Address
#- [-n] KeyVault Secret Name - Name of the KeyVault Secret
################################################################################################################################

# Loop, get parameters & remove any spaces from input
while getopts "k:i:n:" opt; do
    case $opt in
        k)
            # Key Vault Name
            keyVaultName=${OPTARG// /}
        ;;
        i)
            # Virtual Machine IP Address
            vmIPAddress=${OPTARG// /}
        ;;
        n)
            # KeyVault Secret Name
            keyVaultSecretName=${OPTARG// /}
        ;;
        \?)            
            # If user did not provide required parameters then show usage.
            echo "Invalid parameters! Required parameters are:  [-k] Key Vault Name [-i] VM IP Address [-n] Key Vault Secret Name"
        ;;   
    esac
done

# If user did not provide required parameters then non-usage.
if [[ $# -eq 0 || -z $keyVaultName || -z $vmIPAddress || -z $keyVaultSecretName ]]; then
    echo "Parameters missing! Required parameters are:  [-k] Key Vault Name [-i] VM IP Address [-n] Key Vault Secret Name"
    exit 1; 
fi

# retrieve private key and save to build agent
echo "Retrieve key"
echo $(az keyvault secret show -n $keyVaultSecretName --vault-name $keyVaultName --query 'value' --output tsv) | base64 -di > id_rsa

echo "Set folder permissions"
# set proper permissions directory and files
chmod 700 .
chmod 600 *

# add the private key to the authentication agent
eval $(ssh-agent -s)
ssh-add id_rsa

# create .ssh directory and add signaler virtual machine ip address to known_hosts
mkdir ~/.ssh
ssh-keyscan $vmIPAddress >> ~/.ssh/known_hosts