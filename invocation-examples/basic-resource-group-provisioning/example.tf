# Example: Basic Azure Resource Group with Storage and Analytics Provisioning
#
# This example provisions a Resource Group, Storage Account, Log Analytics, and Key Vault using the module.
# Demonstrates the standardized interface with proper security defaults.
#
# Variables:
#   - location: (string, required) Azure region - supports both 'eastus2' and 'East US 2' formats
#   - application_code: (string, required) Application identifier (exactly 4 alphanumeric characters, e.g., "DEMO")
#   - objective_code: (string, required) Purpose code - must be FRNT, BACK, SVLS, AZML, INFR, or SEGU
#   - environment: (string, required) Environment code (P, C, D, F)
#   - correlative: (string, required) 2-digit sequence identifier (e.g., "01", "02")
#   - tags: (map(string), optional) Map of tags to assign to resources
#   - storage_config: (object, required) Consolidated storage configuration object
#   - diagnostic_categories: (list(string), required) Diagnostic log categories for storage account
#   - cost_management: (object, required) Cost management and tagging settings
#   - key_vault_settings: (object, required) Key Vault configuration with security defaults
#   - lock: (object, optional) Resource lock configuration


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
}

variable "location" {
  description = "Azure region for the resource group. Supports both normalized (e.g., 'eastus2') and display name (e.g., 'East US 2') formats."
  type        = string
  default     = "East US 2" # Using display name format to demonstrate flexibility
}

variable "application_code" {
  description = "Application identifier (exactly 4 alphanumeric characters, e.g., 'AP01')."
  type        = string
  default     = "AP01"
}

variable "objective_code" {
  description = "Purpose code for storage naming. Must be one of: FRNT (Front-End), BACK (Back-End), SVLS (ServerLess), AZML (Machine Learning), INFR (Infrastructure), SEGU (Security)."
  type        = string
  default     = "INFR" # Changed from "CORE" to valid option
}

variable "environment" {
  description = "Environment code (one of: P, C, D, F)."
  type        = string
  default     = "D"
}

variable "correlative" {
  description = "Correlative or sequence identifier (2-digit format, e.g., '01', '02')."
  type        = string
  default     = "01"
}

variable "tags" {
  description = "Map of tags to assign to resources."
  type        = map(string)
  default = {
    environment = "dev"
    owner       = "app-team"
  }
}

module "resource_group" {
  source = "../../" # Use relative path to the root module
  # For production, use: source = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-resource-group.git"

  location              = var.location
  application_code      = var.application_code
  objective_code        = var.objective_code
  environment           = var.environment
  correlative           = var.correlative
  tags                  = var.tags
  storage_config        = local.storage_config
  diagnostic_categories = local.diagnostic_categories
  cost_management       = local.cost_management
  key_vault_settings    = local.key_vault_settings
  lock                  = local.lock
}

locals {
  storage_config = {
    # Naming convention (will be replaced by module's locals naming object)
    naming = {
      application_code = var.application_code
      region_code      = "EU2" # This will be overridden by module's region mapping
      environment      = var.environment
      correlative      = var.correlative
      objective_code   = var.objective_code
    }

    # RBAC role assignments (empty for basic example)
    role_assignments = {}

    # Resource tags
    tags = var.tags

    # Resource lock configuration
    lock = null

    # Network settings
    firewall_ips    = []
    vnet_subnet_ids = []

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

  diagnostic_categories = ["StorageRead", "StorageWrite", "StorageDelete"]

  cost_management = {
    tags           = {}
    retention_days = 14
  }

  key_vault_settings = {
    sku_name                        = "premium" # Changed from "standard" to "premium"
    enabled_for_disk_encryption     = true
    enabled_for_deployment          = false
    enabled_for_template_deployment = false
    purge_protection_enabled        = true # Changed from false to true
    soft_delete_retention_days      = 90
    public_network_access_enabled   = false # Changed from true to false (more secure)
    network_acls = {
      bypass                     = "AzureServices"
      default_action             = "Deny" # Changed from "Allow" to "Deny" (more secure)
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
  }

  lock = null
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
