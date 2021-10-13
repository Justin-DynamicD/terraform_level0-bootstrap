# look for tagged s3 bucket
for bucket in `aws s3api list-buckets | jq .Buckets[].Name | tr -d \"`; do
  BUCKETTAG=$(aws s3api get-bucket-tagging --bucket $bucket 2>/dev/null | jq ".TagSet[]|select(.Key ==\"$TAG\")| .Value" | tr -d \")
  if [[ $BUCKETTAG == $ENVNAME ]]; then
    STATEBUCKET=$bucket
    break
  fi
done

if [[ $STATEBUCKET == '' ]]; then
  echo "Could not find a bucket that has the tag '$TAG'='$ENVNAME'."
  echo "Make sure you are logged into AWS and the S3 bucket exists!"
  exit
fi

# grab region from bucket
STATEREGION=$(aws s3api get-bucket-location --bucket $STATEBUCKET 2>/dev/null | jq ".LocationConstraint" | tr -d \")

# look for tagged dynamoDB
# this will only look in the same region s3 resides
for table in `aws dynamodb list-tables --region $STATEREGION 2>/dev/null | jq .TableNames[] | tr -d \"`; do
  TABLEARN=$(aws dynamodb describe-table --table-name $table --region $STATEREGION 2>/dev/null | jq .Table.TableArn | tr -d \")
  TABLETAG=$(aws dynamodb list-tags-of-resource --resource-arn $TABLEARN --region $STATEREGION 2>/dev/null | jq .Tags[].Key | tr -d \")
  if [[ $TABLETAG == *$TAG* ]]; then
    STATETABLE=$table
    break
  fi
done

if [[ $STATETABLE == '' ]]; then
  echo "Could not find a dynamoDB table that has the tag '$TAG'."
  echo "Make sure you are logged into AWS and the table exists!"
  exit
fi

# Echo discovererd values
echo "s3 bucket: $STATEBUCKET"
echo "region: $STATEREGION"
echo "locktable: $STATETABLE"
echo "statefile: $STATEFILE"

if [ $INIT ]; then
  # these statements are captured by Azure Pipelines
  echo "##vso[task.setvariable variable=autoKey;]$STATEFILE"
  echo "##vso[task.setvariable variable=autoKey;isOutput=true]$STATEFILE"
  echo "##vso[task.setvariable variable=autoLockTable;]$STATETABLE"
  echo "##vso[task.setvariable variable=autoLockTable;isOutput=true]$STATETABLE"
  echo "##vso[task.setvariable variable=autoRegion;]$STATEREGION"
  echo "##vso[task.setvariable variable=autoRegion;isOutput=true]$STATEREGION"
  echo "##vso[task.setvariable variable=autoS3;]$STATEBUCKET"
  echo "##vso[task.setvariable variable=autoS3;isOutput=true]$STATEBUCKET"
else
  terraform init \
    -backend-config="bucket=$STATEBUCKET" \
    -backend-config="key=$STATEFILE" \
    -backend-config="region=$STATEREGION" \
    -backend-config="dynamodb_table=$STATETABLE" \
    -upgrade=$UPGRADE
fi