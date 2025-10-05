# Create some environment variables for the next few commands:
RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate15619
CONTAINER_NAME=tfstate

# Create a resource group to store your Terraform state file.
az group create --name $RESOURCE_GROUP_NAME --location eastus

# Create a storage account for your Terraform State file.
az storage account create \
--name $STORAGE_ACCOUNT_NAME \
--resource-group $RESOURCE_GROUP_NAME \
--sku Standard_LRS \
--encryption-services blob

# Create the blob container
az storage container create \
--name $CONTAINER_NAME \
--account-name $STORAGE_ACCOUNT_NAME

# Create a storage container
az storage container create \
--name $CONTAINER_NAME \
--account-name $STORAGE_ACCOUNT_NAME

# Give yourself permissions to access the key locally
ARM_ACCESS_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

terraform fmt

terraform init
