# Consolidated storage configuration as a single object variable
variable "storage_config" {
  description = <<-EOT
    Comprehensive sub-modules configuration object containing all settings.
    
    Includes:
    - naming: Naming convention settings (gonna be replaced by locals naming object)
    - role_assignments: RBAC role assignments
    - tags: Resource tags
    - lock: Resource lock configuration
    - firewall_ips: List of allowed IPv4 addresses
    - vnet_subnet_ids: List of allowed Azure subnet resource IDs
    - storage_settings: Storage account configuration
    - storage_container: Container configuration
    - retention_days: Data retention settings
  EOT
  type = object({
    # Naming convention
    naming = object({
      application_code = string
      region_code      = string
      environment      = string
      correlative      = string
      objective_code   = string
    })

    # RBAC role assignments
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

    # Resource tags
    tags = optional(map(string), {})

    # Resource lock configuration
    lock = optional(object({
      kind = string
      name = string
    }), null)

    # Network settings
    firewall_ips    = optional(list(string), [])
    vnet_subnet_ids = optional(list(string), [])

    # Storage settings
    account_replication_type          = optional(string, "LRS")
    account_tier                      = optional(string, "Standard")
    account_kind                      = optional(string, "StorageV2")
    access_tier                       = optional(string, "Hot")
    large_file_share_enabled          = optional(bool, false)
    is_hns_enabled                    = optional(bool, false)
    nfsv3_enabled                     = optional(bool, false)
    sftp_enabled                      = optional(bool, false)
    queue_encryption_key_type         = optional(string, "Service")
    table_encryption_key_type         = optional(string, "Service")
    infrastructure_encryption_enabled = optional(bool, false)
    blob_versioning_enabled           = optional(bool, false)
    blob_change_feed_enabled          = optional(bool, false)

    # Storage container configuration
    storage_container = optional(object({
      name                  = string
      container_access_type = optional(string, "private")
    }), null)

    # Retention settings
    retention_days = optional(number, 14)
  })

  # Validation for firewall IPs
  validation {
    condition = (
      alltrue([
        for ip in coalesce(var.storage_config.firewall_ips, []) : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
      ])
    )
    error_message = "Each firewall IP must be a valid IPv4 address."
  }

  # Validation for subnet IDs
  validation {
    condition = (
      alltrue([
        for id in coalesce(var.storage_config.vnet_subnet_ids, []) : can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+/subnets/.+$", id))
      ])
    )
    error_message = "Each subnet ID must be a valid Azure subnet resource ID."
  }

  # Validation for storage settings
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_config.account_replication_type)
    error_message = "Invalid value for account_replication_type."
  }
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_config.account_tier)
    error_message = "Invalid value for account_tier."
  }
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.storage_config.account_kind)
    error_message = "Invalid value for account_kind."
  }
  validation {
    condition     = contains(["Hot", "Cool"], var.storage_config.access_tier)
    error_message = "Invalid value for access_tier."
  }
  validation {
    condition     = contains(["Service", "Account"], var.storage_config.queue_encryption_key_type)
    error_message = "queue_encryption_key_type must be 'Service' or 'Account'."
  }
  validation {
    condition     = contains(["Service", "Account"], var.storage_config.table_encryption_key_type)
    error_message = "table_encryption_key_type must be 'Service' or 'Account'."
  }

  # Validation for retention days
  validation {
    condition     = var.storage_config.retention_days >= 1 && var.storage_config.retention_days <= 365
    error_message = "retention_days must be between 1 and 365."
  }

  # Validation for lock kind
  validation {
    condition = (
      var.storage_config.lock == null ||
      contains(["ReadOnly", "Delete"], var.storage_config.lock.kind)
    )
    error_message = "If lock is set, kind must be either 'ReadOnly' or 'Delete'."
  }

}


#variable "diagnostic_settings" {
#  description = "Diagnostic settings for the storage account."
#  type = object({
#    enable_blob    = bool
#    enable_queue   = bool
#    enable_table   = bool
#    enable_file    = bool
#    enable_account = bool
#  })
#  default = {
#    enable_blob    = true
#    enable_queue   = true
#    enable_table   = true
#    enable_file    = true
#    enable_account = true
#  }
#}


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
  description = "Required. The Azure region for deployment of this resource."
  nullable    = false

  validation {
    condition     = length(trim(var.location, " ")) > 0
    error_message = "The location must not be empty."
  }

  validation {
    condition     = contains(keys(local.location_to_region_code), var.location)
    error_message = "The location must be one of the supported Azure regions: ${join(", ", keys(local.location_to_region_code))}."
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