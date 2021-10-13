###
# Storage Backend
###
resource "aws_s3_bucket" "tfstate" {
  for_each  = local.storage_accounts
  bucket    = "${local.global_settings.name_prefix}-${local.global_settings.environment}-${each.key}"
  acl       = "private"
  versioning {
    enabled = true
  }
  tags = merge(local.tags, { (local.global_settings.discovery_tag) = each.value })
}

resource "aws_dynamodb_table" "statelock" {
    name                    = "${local.global_settings.name_prefix}_${local.global_settings.environment}_statelock"
    billing_mode            = "PROVISIONED"
    read_capacity           = 25 #--Max Free Tier
    write_capacity          = 25 #--Max Free Tier
    hash_key                = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    server_side_encryption {
        enabled = true
    }
    tags = merge(local.tags, { (local.global_settings.discovery_tag) = "true" })
}