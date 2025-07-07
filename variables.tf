# =============================================================================
# CORE RESOURCE GROUP MODULE VARIABLES
# =============================================================================

# Location variable (passed to all child modules)
variable "location" {
  type        = string
  description = "Required. The Azure region for deployment of this resource. Supports both normalized form (e.g., 'eastus2') and display name form (e.g., 'East US 2')."
  nullable    = false

  validation {
    condition     = length(trim(var.location, " ")) > 0
    error_message = "The location must not be empty."
  }

  validation {
    condition     = contains(keys(local.location_to_region_code), var.location)
    error_message = "The location must be one of the supported Azure regions. Supported formats include normalized forms (e.g., 'eastus2', 'westus2') and display names (e.g., 'East US 2', 'West US 2'). See local.tf for the complete list."
  }
}

# Naming convention object (passed to all child modules)
variable "naming" {
  description = "Naming convention settings for all resources following Credicorp standards."
  type = object({
    application_code = string
    environment      = string
    correlative      = string
    objective_code   = optional(string, "")
  })
  nullable = false

  validation {
    condition     = can(regex("^[A-Za-z0-9]{4}$", var.naming.application_code))
    error_message = "application_code must be exactly 4 alphanumeric characters."
  }
  validation {
    condition     = contains(["D", "T", "P", "F"], upper(var.naming.environment))
    error_message = "environment must be one of: D (Development), T (Testing), P (Production), F (Formal)."
  }
  validation {
    condition     = can(regex("^[0-9]{2}$", var.naming.correlative))
    error_message = "correlative must be a two-digit string, e.g., '01', '02', etc."
  }
  validation {
    condition     = var.naming.objective_code == "" || can(regex("^[A-Za-z0-9]{3,4}$", var.naming.objective_code))
    error_message = "When provided, objective_code must be 3 or 4 alphanumeric characters (letters or numbers)."
  }
}

# Resource Group configuration object (for this module's resource group)
variable "resource_group_config" {
  description = "Configuration settings for the resource group."
  type = object({
    tags = optional(map(string), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
  })
  default = {
    tags = {}
    lock = null
  }

  validation {
    condition = (
      var.resource_group_config.lock == null ||
      contains(["ReadOnly", "CanNotDelete"], try(var.resource_group_config.lock.kind, ""))
    )
    error_message = "If lock is set, kind must be either 'ReadOnly' or 'CanNotDelete'."
  }
}

# =============================================================================
# CHILD MODULE CONFIGURATION VARIABLES
# =============================================================================

# Storage Account module configuration
variable "storage_config" {
  description = "Configuration object for the storage account module."
  type = object({
    # Required infrastructure settings
    log_analytics_workspace_id = string

    # Resource Group configuration
    resource_group = object({
      create_new = bool
      name       = optional(string, null)
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

    # Resource tags and retention
    tags           = optional(map(string), {})
    retention_days = optional(number, 14)

    # Resource lock configuration
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)

    # Network security settings
    firewall_ips    = optional(list(string), [])
    vnet_subnet_ids = optional(list(string), [])

    # Diagnostic settings
    diagnostic_categories = optional(list(string), ["StorageRead", "StorageWrite", "StorageDelete"])

    # Customer-managed encryption
    customer_managed_key = optional(object({
      key_vault_resource_id = string
      key_name              = string
    }), null)

    # Storage access and replication settings
    allowed_copy_scope               = optional(string, "AAD")
    cross_tenant_replication_enabled = optional(bool, false)
    edge_zone                        = optional(string, null)

    # Storage account settings
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

    # Local user configuration for SFTP
    local_user = optional(map(object({
      name                 = string
      ssh_key_enabled      = optional(bool, false)
      ssh_password_enabled = optional(bool, false)
      permission_scope = optional(list(object({
        resource_name = string
        service       = string
        permissions = object({
          create = optional(bool, false)
          delete = optional(bool, false)
          list   = optional(bool, false)
          read   = optional(bool, false)
          write  = optional(bool, false)
        })
      })), [])
      ssh_authorized_key = optional(list(object({
        description = optional(string, null)
        key         = string
      })), [])
      timeouts = optional(object({
        create = optional(string, null)
        delete = optional(string, null)
        read   = optional(string, null)
        update = optional(string, null)
      }), null)
    })), {})

    # Storage container configuration
    storage_container = optional(object({
      name                  = string
      container_access_type = optional(string, "private")
    }), null)
  })
}

# Key Vault module configuration
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

# Log Analytics module configuration
variable "log_analytics_config" {
  description = "Configuration object for the Log Analytics workspace module."
  type = object({
    # Workspace permissions and security
    allow_resource_only_permissions = optional(bool, false)
    cmk_for_query_forced            = optional(bool, false)
    internet_ingestion_enabled      = optional(bool, false)
    internet_query_enabled          = optional(bool, false)

    # Customer Managed Key configuration
    customer_managed_key = optional(object({
      key_vault_resource_id = string
      key_name              = string
      key_version           = optional(string, null)
      user_assigned_identity = optional(object({
        resource_id = string
      }), null)
    }), null)

    # Managed identity configuration
    identity = optional(object({
      identity_ids = optional(set(string))
      type         = string
    }), null)

    # Timeout configuration
    timeouts = optional(object({
      create = optional(string, null)
      delete = optional(string, null)
      read   = optional(string, null)
      update = optional(string, null)
    }), null)

    # Resource tags
    tags = optional(map(string), {})

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
  })
  default = {
    # Security settings - enforce secure defaults
    allow_resource_only_permissions = false
    cmk_for_query_forced            = false
    internet_ingestion_enabled      = false
    internet_query_enabled          = false

    # No customer managed key by default
    customer_managed_key = null

    # No managed identity by default
    identity = null

    # No custom timeouts by default
    timeouts = null

    # Empty tags by default
    tags = {}

    # No role assignments by default
    role_assignments = {}
  }
}