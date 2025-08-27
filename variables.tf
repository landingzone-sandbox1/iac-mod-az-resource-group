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
      contains(["D", "C", "P", "F"], upper(var.naming.environment))
    )
    error_message = "When provided, environment must be one of: D (Development), C (Certification), P (Production), F (Infrastructure)."
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
    tags                         = optional(map(string), {})
    retention_days               = optional(number, 14)
    network_rules_default_action = optional(string, "Deny") # Default to Deny for security best practice
    # Security settings - Allow override for deployment flexibility
    shared_access_key_enabled = optional(bool, false) # Default false for security, but configurable for deployment needs
    # Network settings - Service Endpoints Configuration
    firewall_ips    = optional(list(string), [])
    vnet_subnet_ids = optional(list(string), [])
    # Deployment lifecycle settings
    enable_deployment_mode        = optional(bool, false) # Temporarily relaxes security for initial deployment
    public_network_access_enabled = optional(bool, false)

    # Diagnostic settings
    diagnostic_categories = optional(list(string), ["StorageRead", "StorageWrite", "StorageDelete"])
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
  description = "Key Vault configuration. Must include resource_group_name (existing), name, sku_name, and diagnostic_settings (mandatory for security compliance)."
  type = object({
    # Required
    tenant_id = string # Azure tenant ID for authentication

    # Basic Configuration (with defaults)
    enabled_for_deployment          = optional(bool, false)       # VM certificate access 
    enabled_for_template_deployment = optional(bool, false)       # ARM template access
    sku_name                        = optional(string, "premium") # standard, premium

    # Security and Network Configuration (environment-specific)
    purge_protection_enabled      = optional(bool)       # Enable/disable purge protection (null = auto based on environment)
    public_network_access_enabled = optional(bool)       # Enable/disable public network access (null = default false)
    soft_delete_retention_days    = optional(number, 90) # Soft delete retention period

    # Resource Management
    resource_group_name = optional(object({
      create_new = bool
      name       = optional(string, null)
    }))
    lock = optional(object({
      kind = string # CanNotDelete, ReadOnly
      name = optional(string, null)
    }))

    # Network Access Control
    network_acls = optional(object({
      bypass                     = optional(string, "AzureServices") # AzureServices, None
      default_action             = optional(string, "Deny")          # Allow, Deny
      ip_rules                   = optional(list(string), [])        # CIDR blocks
      virtual_network_subnet_ids = optional(list(string), [])        # Subnet IDs
    }))

    # Legacy Access Policies (for backwards compatibility)
    legacy_access_policies_enabled = optional(bool, false)
    legacy_access_policies = optional(map(object({
      object_id               = string
      application_id          = optional(string)
      certificate_permissions = optional(list(string))
      key_permissions         = optional(list(string))
      secret_permissions      = optional(list(string))
      storage_permissions     = optional(list(string))
    })), {})

    # Private Endpoints
    private_endpoints = optional(map(object({
      subnet_resource_id              = string
      private_dns_zone_resource_ids   = optional(list(string), [])
      private_dns_zone_group_name     = optional(string, "default")
      private_service_connection_name = optional(string)
      name                            = optional(string)
      location                        = optional(string)
      resource_group_name             = optional(string)
      is_manual_connection            = optional(bool, false)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = string
      })), {})
      tags = optional(map(string), {})
    })), {})

    # Key Vault Keys
    keys = optional(map(object({
      name     = string
      key_type = string                 # RSA, EC, RSA-HSM, EC-HSM
      key_size = optional(number, 2048) # For RSA keys: 2048, 3072, 4096
      curve    = optional(string)       # For EC keys: P-256, P-384, P-521, P-256K
      key_opts = list(string)           # decrypt, encrypt, sign, unwrapKey, verify, wrapKey

      rotation_policy = optional(object({
        automatic = optional(object({
          time_after_creation = optional(string) # ISO 8601 duration
          time_before_expiry  = optional(string) # ISO 8601 duration
        }))
        expire_after         = optional(string) # ISO 8601 duration
        notify_before_expiry = optional(string) # ISO 8601 duration
      }))

      not_before_date = optional(string) # RFC 3339 date
      expiration_date = optional(string) # RFC 3339 date
      tags            = optional(map(string), {})
    })), {})

    # Key Vault Secrets
    secrets = optional(map(object({
      name            = string
      value           = optional(string) # Optional - enables template secrets without values
      content_type    = optional(string) # MIME type
      not_before_date = optional(string) # RFC 3339 date
      expiration_date = optional(string) # RFC 3339 date
      tags            = optional(map(string), {})
    })), {})

    # Key Vault Certificates
    certificates = optional(map(object({
      name = string

      # Certificate Policy
      certificate_policy = object({
        issuer_parameters = object({
          name = string # Self, Unknown, or certificate authority name
        })

        key_properties = object({
          exportable = bool
          key_size   = number
          key_type   = string # RSA, EC
          reuse_key  = bool
        })

        lifetime_actions = optional(list(object({
          action = object({
            action_type = string # AutoRenew, EmailContacts
          })
          trigger = object({
            days_before_expiry  = optional(number)
            lifetime_percentage = optional(number)
          })
        })), [])

        secret_properties = object({
          content_type = string # application/x-pkcs12, application/x-pem-file
        })

        x509_certificate_properties = optional(object({
          extended_key_usage = optional(list(string), [])
          key_usage          = list(string)
          subject            = string
          validity_in_months = number

          subject_alternative_names = optional(object({
            dns_names = optional(list(string), [])
            emails    = optional(list(string), [])
            upns      = optional(list(string), [])
          }))
        }))
      })

      # Certificate attributes
      not_before_date = optional(string)
      expiration_date = optional(string)
      tags            = optional(map(string), {})
    })), {})

    # Resource Tags
    tags = optional(map(string), {})

    # LT-4: Diagnostic Settings for Security Investigation (NUEVO LBS) - MANDATORY
    diagnostic_settings = map(object({
      name                       = string
      log_analytics_workspace_id = string # REQUIRED - only Log Analytics allowed

      # LBS requirement: AuditEvent logs for security investigation
      enabled_logs = optional(list(object({
        category       = optional(string)
        category_group = optional(string)
        })), [
        {
          category_group = "audit" # Required by LBS for AuditEvent logs
        }
      ])

      # Performance and security metrics
      metrics = optional(list(object({
        category = string
        enabled  = optional(bool, true)
        })), [
        {
          category = "AllMetrics"
          enabled  = true
        }
      ])
    }))
  })

  default = {
    tenant_id = ""

    enabled_for_deployment          = false
    enabled_for_template_deployment = false
    sku_name                        = "premium"

    purge_protection_enabled      = null
    public_network_access_enabled = null
    soft_delete_retention_days    = 90

    resource_group_name = {
      create_new = false
      name       = null
    }
    lock = null

    network_acls = {
      bypass                     = "AzureServices"
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    legacy_access_policies_enabled = false
    legacy_access_policies         = {}

    private_endpoints = {}

    keys         = {}
    secrets      = {}
    certificates = {}

    tags = {}

    diagnostic_settings = {}
  }
}
    