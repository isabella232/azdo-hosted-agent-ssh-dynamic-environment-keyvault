#!/bin/bash -eu

################################################################################################################################
#- Purpose: Script is used to deploy the mcr.microsoft.com/dotnet/core/samples:aspnetapp image an Azure Virtual Machine
#- Parameters are:
#- [-d] Docker Image Name - Docker Image Name
#- [-v] Virtual Machine Username - Virtual Machine Username
#- [-i] Virtual Machine IP Address - IP Address of Virtual Machine
#- [-k] KeyVaultName - Azure Key Vault name
#- [-d] Key Install Script Directory - Directory where the ssh-key-install.sh script resides
################################################################################################################################

containerName="aspnetcoreapp"
keyVaultSecretName="vm-private-key"

# Loop, get parameters & remove any spaces from input
while getopts "a:v:i:k:d:" opt; do
    case $opt in
        a)
            # Docker Image
            dockerImageName=${OPTARG// /}
        ;;
        v)
            # Virtual Machine Username
            vmUsername=${OPTARG// /}
        ;;
        i)
            # Virtual Machine IP Address
            vmIPAddress=${OPTARG// /}
        ;;        
        k)
            # Key Vault Name
            keyVaultName=${OPTARG// /}
        ;;  
        d)
            # Key Install Script Directory
            keyInstallScriptDirectory=${OPTARG// /}
        ;;        
        \?)            
            # If user did not provide required parameters then show usage.
            echo "Invalid parameters! Required parameters are:  [-d] Docker Image Name [-v] VM Username [-i] VM Password [-k] Key Vault Name [d] Key Install Script Directory"
        ;;
    esac
done

# If user did not provide required parameters then shoaciName usage.
if [[ $# -eq 0 || -z $dockerImageName || -z $vmUsername || -z $vmIPAddress || -z $keyVaultName || -z $keyInstallScriptDirectory ]]; then
    echo "Parameters missing! Required parameters are:  [-d] Docker Image Name [-v] VM Username [-i] VM Password [-k] Key Vault Name [d] Key Install Script Directory"
    exit 1; 
fi

# set execute permissions and install private key
echo "Installing private key..."
chmod +x $keyInstallScriptDirectory/ssh-key-install.sh
. $keyInstallScriptDirectory/ssh-key-install.sh -k $keyVaultName -i $vmIPAddress -n $keyVaultSecretName

# pulling image
echo "Pulling latest image..."
docker -H ssh://$vmUsername@$vmIPAddress pull $dockerImageName

# check to see if container is running attempting to stop existing container
if docker -H ssh://$vmUsername@$vmIPAddress ps -a --format '{{.Names}}' | grep -Eq "^${containerName}\$"; then
 echo "Stopping the current container..."
 docker -H ssh://$vmUsername@$vmIPAddress stop $containerName
 docker -H ssh://$vmUsername@$vmIPAddress rm $containerName
fi

# run new container
echo "Starting new containers..."
docker -H ssh://$vmUsername@$vmIPAddress run --name $containerName -d -p 8000:80 $dockerImageName

# check to see if new container is running
if ! docker -H ssh://$vmUsername@$vmIPAddress ps -a --format '{{.Names}}' | grep -Eq "^${containerName}\$"; then
  echo "Error: Not able to start the container"
  exit 1
else
  echo "Container $containerName version $dockerImage is now running..."
fi