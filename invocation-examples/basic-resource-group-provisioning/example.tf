# Example: Basic Azure Resource Group with Storage and Analytics Provisioning
#
# This example provisions a Resource Group, Storage Account, Log Analytics, and Key Vault using the module.
# Demonstrates the standardized interface with proper security defaults.
# This example provisions a Resource Group, Storage Account, Log Analytics, and Key Vault using the module.
# Demonstrates the standardized interface with proper security defaults.
#
# Variables:
#   - location: (string, required) Azure region - supports both 'eastus2' and 'East US 2' formats
#   - naming: (object, required) Naming convention object with application_code, environment, correlative, objective_code
#   - resource_group_config: (object, required) Resource Group specific configuration (tags, lock)
#   - storage_config: (object, required) Consolidated storage configuration object
#   - key_vault_settings: (object, required) Key Vault configuration with security defaults


terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.28.0"
    }
  }
}

provider "azurerm" {
  features {}
  
  # Use Azure AD authentication for storage operations instead of storage account keys
  # This is required when storage accounts have shared_access_key_enabled = false
  storage_use_azuread = true
}

variable "location" {
  description = "Azure region for the resource group. Supports both normalized (e.g., 'eastus2') and display name (e.g., 'East US 2') formats."
  type        = string
  default     = "East US 2" # Using display name format to demonstrate flexibility
}

module "resource_group" {
  source = "../../" # Use relative path to the root module
  # For production, use: source = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-resource-group.git"

  location = var.location

  # Naming convention
  naming = {
    application_code = "DEMO"  # Changed to 4 letters as required by storage account validation
    environment      = "D"
    correlative      = "01"
    objective_code   = "INFR"
  }

  # Resource Group configuration
  resource_group_config = {
    tags = {
      environment = "dev"
      owner       = "app-team"
      project     = "demo"
    }
    lock = null # No lock for this example
  }

  # Storage Account configuration (includes diagnostic categories)
  storage_config = {
    # Naming convention (will be replaced by module's locals naming object)
    naming = {
      application_code = "DEMO"  # Changed to 4 letters as required by storage account validation
      region_code      = "EU2" # This will be overridden by module's region mapping
      environment      = "D"
      correlative      = "01"
      objective_code   = "INFR"
    }

    # RBAC role assignments (empty for basic example)
    role_assignments = {}

    # Resource tags
    tags = {}

    # Resource lock configuration
    lock = null

    # Network settings
    firewall_ips    = []
    vnet_subnet_ids = []

    # Diagnostic categories (specific to storage account)
    diagnostic_categories = ["StorageRead", "StorageWrite", "StorageDelete"]

    # Storage settings
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

    # Storage container configuration
    storage_container = {
      name                  = "default"
      container_access_type = "private"
    }

    # Retention settings
    retention_days = 14
  }

  # Log Analytics configuration
  log_analytics_config = {
    # Security settings - enforce secure defaults
    allow_resource_only_permissions = false
    cmk_for_query_forced            = false
    internet_ingestion_enabled      = false
    internet_query_enabled          = false

    # RBAC role assignments (empty for basic example)
    role_assignments = {}

    # Resource tags
    tags = {
      environment = "dev"
      component   = "monitoring"
    }

    # Optional configurations (set to null for basic example)
    customer_managed_key = null
    identity             = null
    timeouts             = null
  }

  # Key Vault settings
  key_vault_settings = {
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

# Outputs
output "resource_group_name" {
  description = "The name of the resource group."
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "The resource ID of the resource group."
  value       = module.resource_group.resource_group_id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  value       = module.resource_group.log_analytics_workspace_name
}

output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace."
  value       = module.resource_group.log_analytics_workspace_id
}

output "storage_account" {
  description = "Object containing key storage account outputs."
  value       = module.resource_group.storage_account
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = module.resource_group.key_vault_name
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault."
  value       = module.resource_group.key_vault_id
}
