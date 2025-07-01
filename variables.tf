variable "network_and_rbac_settings" {
  description = "Network and RBAC configuration for the storage account."
  type = object({
    firewall_ips    = optional(list(string), [])
    vnet_subnet_ids = optional(list(string), [])
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      principal_type                         = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
  })
  default = {}
}



variable "storage_container" {
  description = "Configuration for the storage container. Set to null to skip container creation."
  type = object({
    name                  = string
    container_access_type = optional(string, "private")
  })
  default = null
}

variable "diagnostic_settings" {
  description = "Diagnostic settings for the storage account."
  type = object({
    enable_blob                = bool
    enable_queue               = bool
    enable_table               = bool
    enable_file                = bool
    enable_account             = bool
    log_analytics_workspace_id = string
  })
  default = {
    enable_blob                = true
    enable_queue               = false
    enable_table               = false
    enable_file                = false
    enable_account             = true
    log_analytics_workspace_id = ""
  }
}

variable "storage_settings" {
  description = "General storage account settings."
  type = object({
    account_replication_type          = string
    account_tier                      = string
    account_kind                      = string
    access_tier                       = string
    large_file_share_enabled          = bool
    is_hns_enabled                    = bool
    nfsv3_enabled                     = bool
    sftp_enabled                      = bool
    queue_encryption_key_type         = string
    table_encryption_key_type         = string
    infrastructure_encryption_enabled = bool
    blob_versioning_enabled           = optional(bool, false)
    blob_change_feed_enabled          = optional(bool, false)
  })
  default = {
    account_replication_type          = "LRS"
    account_tier                      = "Standard"
    account_kind                      = "StorageV2"
    access_tier                       = "Hot"
    large_file_share_enabled          = false
    is_hns_enabled                    = false
    nfsv3_enabled                     = false
    sftp_enabled                      = false
    queue_encryption_key_type         = "Service"
    table_encryption_key_type         = "Service"
    infrastructure_encryption_enabled = false
    blob_versioning_enabled           = false
    blob_change_feed_enabled          = false
  }
}

variable "key_vault_settings" {
  description = "Configuration settings for the Key Vault."
  type = object({
    sku_name                        = string
    enabled_for_disk_encryption     = bool
    enabled_for_deployment          = bool
    enabled_for_template_deployment = bool
    purge_protection_enabled        = bool
    soft_delete_retention_days      = number
    public_network_access_enabled   = bool
    network_acls = object({
      bypass                     = string
      default_action             = string
      ip_rules                   = list(string)
      virtual_network_subnet_ids = list(string)
    })
  })
  default = {
    sku_name                        = "premium"
    enabled_for_disk_encryption     = true
    enabled_for_deployment          = false
    enabled_for_template_deployment = false
    purge_protection_enabled        = true
    soft_delete_retention_days      = 90
    public_network_access_enabled   = false
    network_acls = {
      bypass                     = "AzureServices"
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
  }
}

variable "cost_management" {
  description = "Cost management and tagging settings."
  type = object({
    tags           = map(string)
    retention_days = number
  })
  default = {
    tags           = {}
    retention_days = 14
  }
}

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
  description = "Application environment (P, C, D, F)."
  nullable    = false
  validation {
    condition     = contains(["P", "C", "D", "F"], var.environment)
    error_message = "The environment must be one of: P, C, D, F."
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

variable "objective_code" {
  description = "A 3 to 4 character code conveying a meaningful purpose for the resource (e.g., core, mgmt)."
  type        = string
  validation {
    condition     = var.objective_code == "" || can(regex("^[A-Za-z0-9]{3,4}$", var.objective_code))
    error_message = "When provided, objective code must be 3 or 4 alphanumeric characters (letters or numbers). See: https://github.com/landingzone-sandbox/wiki-landing-zone/wiki/ALZ-+-GEN-IA-Landing-Zone-(MS-English)-(M1)---Resource-Organization-Naming-Convention-Standards"
  }

}

variable "diagnostic_categories" {
  description = "List of diagnostic log categories to enable for the storage account."
  type        = list(string)
  default     = ["StorageRead", "StorageWrite", "StorageDelete"]
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


# Consolidated naming object for all naming-related properties
variable "naming" {
  description = "Naming convention object for resource naming."
  type = object({
    application_code = string # 4 alphanumeric characters
    region_code      = string # e.g., 'EU2'
    environment      = string # P, C, D, F
    correlative      = string # sequence identifier
    objective_code   = string # 3-4 uppercase alphanumeric characters
  })
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{4}$", var.naming.application_code))
    error_message = "The application_code must be exactly 4 alphanumeric characters."
  }
  validation {
    condition     = can(regex("^[A-Z0-9]{2,}$", var.naming.region_code))
    error_message = "The region_code must be uppercase letters and/or numbers (e.g., 'EU2')."
  }
  validation {
    condition     = contains(["P", "C", "D", "F"], var.naming.environment)
    error_message = "The environment must be one of: P, C, D, F."
  }
  validation {
    condition     = length(trim(var.naming.correlative, " ")) > 0
    error_message = "The correlative must not be empty."
  }
  validation {
    condition     = can(regex("^[A-Z0-9]{3,4}$", var.naming.objective_code))
    error_message = "The objective_code must be 3-4 uppercase alphanumeric characters."
  }
}