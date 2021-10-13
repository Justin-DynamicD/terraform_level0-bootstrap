# look for tagged storage account
STATESA=$(az storage account list --query "[?tags.$TAG=='$ENVNAME'].name" --output json | jq .[0] | tr -d \")

if [[ $STATESA == '' ]]; then
  echo "Could not find a storage account that has the tag '$TAG' and is designated for $ENVNAME."
  echo "Make sure you are logged into Azure and the SA exists!"
  exit
fi

# grab region and resource group from the storage acccount
sadetails=$(az storage account show --name $STATESA)
STATEREGION=$(echo $sadetails | jq .location | tr -d \")
STATERESOURCEGROUP=$(echo $sadetails | jq .resourceGroup | tr -d \")

# Echo discovererd values
echo "container: $ENVNAME"
echo "key: $STATEFILE"
echo "region: $STATEREGION"
echo "resource group: $STATERESOURCEGROUP"
echo "storage account: $STATESA"

if [ $INIT ]; then
  # these statements are captured by Azure Pipelines
  echo "##vso[task.setvariable variable=autoContainer;]$ENVNAME"
  echo "##vso[task.setvariable variable=autoContainer;isOutput=true]$ENVNAME"
  echo "##vso[task.setvariable variable=autoKey;]$STATEFILE"
  echo "##vso[task.setvariable variable=autoKey;isOutput=true]$STATEFILE"
  echo "##vso[task.setvariable variable=autoRegion;]$STATEREGION"
  echo "##vso[task.setvariable variable=autoRegion;isOutput=true]$STATEREGION"
  echo "##vso[task.setvariable variable=autoResourceGroup;]$STATERESOURCEGROUP"
  echo "##vso[task.setvariable variable=autoResourceGroup;isOutput=true]$STATERESOURCEGROUP"
  echo "##vso[task.setvariable variable=autoStorageAccount;]$STATESA"
  echo "##vso[task.setvariable variable=autoStorageAccount;isOutput=true]$STATESA"
else
  terraform init \
    -backend-config="resource_group_name=$STATERESOURCEGROUP" \
    -backend-config="storage_account_name=$STATESA" \
    -backend-config="container_name=$ENVNAME" \
    -backend-config="key=$STATEFILE" \
    -upgrade=$UPGRADE
fi