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
  description = "Naming convention settings for all resources following Credicorp standards. All fields are optional to allow workspace-specific overrides."
  type = object({
    application_code = optional(string, null)
    environment      = optional(string, null)
    correlative      = optional(string, null)
    objective_code   = optional(string, "")
  })
  default = {
    application_code = null
    environment      = null
    correlative      = null
    objective_code   = ""
  }

  validation {
    condition = (
      var.naming.application_code == null ||
      can(regex("^[A-Za-z0-9]{4}$", var.naming.application_code))
    )
    error_message = "When provided, application_code must be exactly 4 alphanumeric characters."
  }
  validation {
    condition = (
      var.naming.environment == null ||
      contains(["D", "T", "P", "F"], upper(var.naming.environment))
    )
    error_message = "When provided, environment must be one of: D (Development), T (Testing), P (Production), F (Formal)."
  }
  validation {
    condition = (
      var.naming.correlative == null ||
      can(regex("^[0-9]{2}$", var.naming.correlative))
    )
    error_message = "When provided, correlative must be a two-digit string, e.g., '01', '02', etc."
  }
  validation {
    condition = (
      var.naming.objective_code == "" ||
      can(regex("^[A-Za-z0-9]{3,4}$", var.naming.objective_code))
    )
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
    # Required infrastructure settings (provided by orchestration)
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

# =============================================================================
# FALLBACK VARIABLES FOR NAMING FIELDS
# =============================================================================
# These variables provide fallback values when naming object fields are null
# Useful for workspace-specific overrides or backward compatibility

variable "fallback_application_code" {
  description = "Fallback application code when naming.application_code is null. Must be exactly 4 alphanumeric characters."
  type        = string
  default     = "DEMO"
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9]{4}$", var.fallback_application_code))
    error_message = "fallback_application_code must be exactly 4 alphanumeric characters."
  }
}

variable "fallback_environment" {
  description = "Fallback environment when naming.environment is null. Must be one of: D, T, P, F."
  type        = string
  default     = "D"
  nullable    = false

  validation {
    condition     = contains(["D", "T", "P", "F"], upper(var.fallback_environment))
    error_message = "fallback_environment must be one of: D (Development), T (Testing), P (Production), F (Formal)."
  }
}

variable "fallback_correlative" {
  description = "Fallback correlative when naming.correlative is null. Must be a two-digit string."
  type        = string
  default     = "01"
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]{2}$", var.fallback_correlative))
    error_message = "fallback_correlative must be a two-digit string, e.g., '01', '02', etc."
  }
}

variable "fallback_objective_code" {
  description = "Fallback objective code when naming.objective_code is empty. Must be 3 or 4 alphanumeric characters."
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.fallback_objective_code == "" || can(regex("^[A-Za-z0-9]{3,4}$", var.fallback_objective_code))
    error_message = "When provided, fallback_objective_code must be 3 or 4 alphanumeric characters (letters or numbers)."
  }
}