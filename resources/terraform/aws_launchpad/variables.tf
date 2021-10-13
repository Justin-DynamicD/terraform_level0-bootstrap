######
# global variables
######

variable global_settings {
  type        = map(any)
  description = "map of global variables"
  default     = null
}

variable ecr_repository {
  type        = map(any)
  description = "map of ECR variables"
  default     = null
}

variable storage_accounts {
  type        = map(any)
  description = "map of storage account variables"
  default     = null
}

variable tags {
  type        = map(any)
  description = "map of tags to apply to all resources"
  default     = null
}