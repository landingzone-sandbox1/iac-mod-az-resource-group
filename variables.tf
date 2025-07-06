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
      try(contains(["ReadOnly", "Delete"], var.storage_config.lock.kind), false)
    )
    error_message = "If lock is set, kind must be either 'ReadOnly' or 'Delete'."
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

# Core module inputs
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

variable "naming" {
  description = "Naming convention settings for all resources."
  type = object({
    application_code = string
    environment      = string
    correlative      = string
    objective_code   = string
  })
  nullable = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{4}$", var.naming.application_code))
    error_message = "The application_code must be exactly 4 alphanumeric characters."
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
    condition     = var.naming.objective_code == "" || can(regex("^[A-Za-z0-9]{3,4}$", var.naming.objective_code))
    error_message = "When provided, objective code must be 3 or 4 alphanumeric characters (letters or numbers)."
  }
}

# Resource Group specific configuration
variable "resource_group_config" {
  description = <<-EOT
    Resource Group specific configuration settings.
    
    Includes:
    - tags: Resource tags for the resource group
    - lock: Resource lock configuration
  EOT
  type = object({
    # Resource tags
    tags = optional(map(string), {})

    # Resource lock configuration
    lock = optional(object({
      kind = optional(string, "ReadOnly")
      name = optional(string, null)
    }), null)
  })
  default = {
    tags = {}
    lock = null
  }

  validation {
    condition     = var.resource_group_config.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.resource_group_config.lock.kind) : true
    error_message = "Lock kind must be either \"CanNotDelete\" or \"ReadOnly\"."
  }
}

variable "log_analytics_config" {
  description = "Configuration settings for the Log Analytics Workspace."
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

    # Timeout configuration
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }), null)
  })
  default = {
    # Security settings - enforce secure defaults
    allow_resource_only_permissions = false
    cmk_for_query_forced            = false
    internet_ingestion_enabled      = false
    internet_query_enabled          = false

    # Empty defaults for optional configurations
    customer_managed_key = null
    identity             = null
    role_assignments     = {}
    tags                 = {}
    timeouts             = null
  }

  # Validate identity configuration
  validation {
    condition = (
      var.log_analytics_config.identity == null ||
      contains(["SystemAssigned", "UserAssigned"], try(var.log_analytics_config.identity.type, ""))
    )
    error_message = "If identity is set, type must be either 'SystemAssigned' or 'UserAssigned'."
  }

  # Validate identity_ids for UserAssigned type
  validation {
    condition = (
      var.log_analytics_config.identity == null ||
      try(var.log_analytics_config.identity.type, null) != "UserAssigned" ||
      try(var.log_analytics_config.identity.identity_ids, null) != null
    )
    error_message = "When identity type is 'UserAssigned', identity_ids must be provided."
  }

  # Validate customer_managed_key configuration
  validation {
    condition = (
      var.log_analytics_config.customer_managed_key == null ||
      (try(var.log_analytics_config.customer_managed_key.key_vault_resource_id, null) != null &&
      try(var.log_analytics_config.customer_managed_key.key_name, null) != null)
    )
    error_message = "If customer_managed_key is set, both key_vault_resource_id and key_name must be provided."
  }

  # Validate role assignment principal types
  validation {
    condition = (
      length(coalesce(var.log_analytics_config.role_assignments, {})) == 0 ||
      alltrue([
        for ra in values(var.log_analytics_config.role_assignments) : (
          contains(["ServicePrincipal", "ManagedIdentity"], ra.principal_type)
        )
      ])
    )
    error_message = "If set, all role assignments must have principal_type set to 'ServicePrincipal' or 'ManagedIdentity'."
  }

  # Enforce least-privilege roles only
  validation {
    condition = (
      length(coalesce(var.log_analytics_config.role_assignments, {})) == 0 ||
      alltrue([
        for ra in values(var.log_analytics_config.role_assignments) : (
          contains([
            # Log Analytics specific roles (read-only for least privilege)
            "Log Analytics Reader",
            # Monitoring roles (read-only and metrics publishing only)
            "Monitoring Reader",
            "Monitoring Metrics Publisher",
            # Security roles (read-only only)
            "Security Reader"
          ], ra.role_definition_id_or_name)
        )
      ])
    )
    error_message = "Only true least-privilege roles are allowed: Log Analytics Reader, Monitoring Reader, Monitoring Metrics Publisher, Security Reader. Administrative roles like Contributors, Admins, Owners are not permitted."
  }
}