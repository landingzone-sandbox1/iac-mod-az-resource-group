variable "location" {
  type        = string
  description = "Required. The Azure region for deployment of the this resource."
  nullable    = false
  validation {
    condition     = length(trim(var.location, " ")) > 0
    error_message = "The location must not be empty."
  }
}

variable "application_code" {
  type        = string
  description = "Application code or service code."
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{4}$", var.application_code))
    error_message = "The application_code must be exactly 4 alphanumeric characters."
  }
}

variable "region_code" {
  type        = string
  description = "Region code (e.g., 'EU2'for EastUS2)."
  nullable    = false
  validation {
    condition     = can(regex("^[A-Z0-9]{2,}$", var.region_code))
    error_message = "The region_code must be uppercase letters and/or numbers (e.g., 'EU2')."
  }
}

variable "environment" {
  type        = string
  description = "Application environment (P, C, D)."
  nullable    = false
  validation {
    condition     = contains(["P", "C", "D"], var.environment)
    error_message = "The environment must be one of: P, C, D."
  }
}

variable "correlative" {
  description = "Correlative or sequence identifier for the resource group."
  type        = string
  validation {
    condition     = length(trim(var.correlative, " ")) > 0
    error_message = "The correlative must not be empty."
  }
}

variable "lock" {
  type = object({
    kind = optional(string, "ReadOnly")
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:
  
  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

# Storage Account Variables
variable "objective_code" {
  type        = string
  description = "3-4 character code for resource purpose (e.g., STOR, CORE)."
  nullable    = false
  validation {
    condition     = can(regex("^[A-Z0-9]{3,4}$", var.objective_code))
    error_message = "The objective_code must be 3-4 uppercase alphanumeric characters."
  }
}

variable "log_analytics_objective_code" {
  type        = string
  description = "3-4 character purpose code for Log Analytics workspace (e.g., MON, LOG)."
  default     = "MON"
  validation {
    condition     = can(regex("^[A-Z0-9]{3,4}$", var.log_analytics_objective_code))
    error_message = "The log_analytics_objective_code must be 3-4 uppercase alphanumeric characters."
  }
}

variable "account_replication_type" {
  type        = string
  description = "Storage account replication type."
  default     = "ZRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "The account_replication_type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "storage_account_tier" {
  type        = string
  description = "Storage account tier."
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The storage_account_tier must be either Standard or Premium."
  }
}

variable "account_kind" {
  type        = string
  description = "Storage account kind."
  default     = "StorageV2"
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "The account_kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "access_tier" {
  type        = string
  description = "Storage account access tier."
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "The access_tier must be either Hot or Cool."
  }
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "Enable shared access key for storage account."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access for storage account."
  default     = false
}

variable "firewall_ips" {
  type        = list(string)
  description = "List of IP addresses or CIDR blocks to allow access to storage account."
  default     = null
}

variable "vnet_subnet_ids" {
  type        = list(string)
  description = "List of virtual network subnet IDs to allow access to storage account."
  default     = null
}

variable "blob_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted blobs."
  default     = 7
  validation {
    condition     = var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365
    error_message = "The blob_delete_retention_days must be between 1 and 365."
  }
}

variable "container_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted containers."
  default     = 7
  validation {
    condition     = var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365
    error_message = "The container_delete_retention_days must be between 1 and 365."
  }
}

variable "blob_versioning_enabled" {
  type        = bool
  description = "Enable blob versioning."
  default     = true
}

variable "storage_container" {
  type = object({
    name                  = string
    container_access_type = optional(string, "private")
  })
  description = "Storage container configuration."
  default     = null
  validation {
    condition     = var.storage_container != null ? contains(["blob", "container", "private"], var.storage_container.container_access_type) : true
    error_message = "The container_access_type must be one of: blob, container, private."
  }
}

# Log Analytics Workspace Variables
variable "log_analytics_sku" {
  type        = string
  description = "Log Analytics workspace SKU."
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_sku)
    error_message = "The log_analytics_sku must be one of: Free, Standalone, PerNode, PerGB2018."
  }
}

variable "log_analytics_retention_days" {
  type        = number
  description = "Log Analytics workspace retention in days."
  default     = 30
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "The log_analytics_retention_days must be between 30 and 730."
  }
}

variable "log_analytics_daily_quota_gb" {
  type        = number
  description = "Log Analytics workspace daily quota in GB."
  default     = -1
}

variable "log_analytics_workspace_allow_resource_only_permissions" {
  type        = bool
  description = "Allow resource-only permissions for the Log Analytics workspace."
  default     = true
}

variable "log_analytics_workspace_cmk_for_query_forced" {
  type        = bool
  description = "Require customer-managed key for query operations."
  default     = false
}

variable "log_analytics_workspace_internet_ingestion_enabled" {
  type        = bool
  description = "Enable ingestion over public internet for the Log Analytics workspace."
  default     = true
}

variable "log_analytics_workspace_internet_query_enabled" {
  type        = bool
  description = "Enable query over public internet for the Log Analytics workspace."
  default     = true
}

variable "log_analytics_workspace_local_authentication_disabled" {
  type        = bool
  description = "Disable local authentication (use Azure AD only)."
  default     = false
}

