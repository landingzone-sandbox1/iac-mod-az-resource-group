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
    condition     = contains(["D", "C", "P", "F"], upper(var.naming.environment))
    error_message = "environment must be one of: D (Development), C (Certification), P (Production), F (Formal)."
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
    tags        = optional(map(string), {})
    apply_locks = optional(bool, false)
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
  })
  default = {
    tags        = {}
    apply_locks = false
    lock        = null
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
    # Infrastructure settings (provided by orchestration)
    log_analytics_workspace_id = optional(string, null)

    # Resource Group configuration (provided by orchestration)
    resource_group = optional(object({
      create_new = bool
      name       = optional(string, null)
    }), null)

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
  })
  default = {}
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

    # Resource tags
    tags = optional(map(string), {})
  })
  default = {}
}

# Key Vault module configuration
variable "keyvault_config" {
  description = "Configuration settings for the Key Vault."
  type = object({
    sku_name                        = optional(string, "standard")
    enabled_for_disk_encryption     = optional(bool, true)
    enabled_for_deployment          = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    purge_protection_enabled        = optional(bool, true)
    soft_delete_retention_days      = optional(number, 90)
    public_network_access_enabled   = optional(bool, false)
    network_acls = optional(object({
      bypass                     = optional(string, "AzureServices")
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
      }), {
      bypass                     = "AzureServices"
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    })
    tags = optional(map(string), {})
  })
  default = {}
}