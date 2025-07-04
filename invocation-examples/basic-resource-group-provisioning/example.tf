# Example: Basic Azure Resource Group with Storage and Analytics Provisioning
#
# This example provisions a Resource Group, Storage Account, and Log Analytics using the module.
#
# Variables:
#   - location: (string, required) Azure region for the resource group (e.g., "eastus2").
#   - application_code: (string, required) Application identifier (exactly 4 alphanumeric characters, e.g., "AP01").
#   - objective_code: (string, required) Purpose code for storage naming (3-4 uppercase alphanumeric chars, e.g., "CORE").
#   - environment: (string, required) Environment code (one of: P, C, D, F).
#   - correlative: (string, required) Unique identifier or numeric suffix (non-empty string, e.g., "01").
#   - tags: (map(string), optional) Map of tags to assign to resources.
#   - storage_config: (object, required) Consolidated storage configuration object.
#   - diagnostic_categories: (list(string), required) Diagnostic log categories for storage account.
#   - cost_management: (object, required) Cost management and tagging settings.
#   - key_vault_settings: (object, required) Key Vault configuration settings.
#   - lock: (object, optional) Resource lock configuration.


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
  description = "Azure region for the resource group."
  type        = string
  default     = "eastus2"
}

variable "application_code" {
  description = "Application identifier (exactly 4 alphanumeric characters, e.g., 'AP01')."
  type        = string
  default     = "AP01"
}

variable "objective_code" {
  description = "Purpose code for storage naming (3-4 uppercase alphanumeric chars, e.g., 'CORE')."
  type        = string
  default     = "CORE"
}

variable "environment" {
  description = "Environment code (one of: P, C, D, F)."
  type        = string
  default     = "D"
}

variable "correlative" {
  description = "Unique identifier or numeric suffix (non-empty string, e.g., '01')."
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
source = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-resource-group.git"
  location         = var.location
  application_code = var.application_code
  objective_code   = var.objective_code
  environment      = var.environment
  correlative      = var.correlative
  tags             = var.tags
  storage_config   = local.storage_config
  diagnostic_categories = local.diagnostic_categories
  cost_management  = local.cost_management
  key_vault_settings = local.key_vault_settings
  lock             = local.lock
}

locals {
  storage_config = {
    # Naming convention (will be replaced by locals naming object)
    naming = {
      application_code = var.application_code
      region_code      = "EUS2"
      environment      = var.environment
      correlative      = var.correlative
      objective_code   = var.objective_code
    }

    # RBAC role assignments
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
    sku_name                        = "standard"
    enabled_for_disk_encryption     = true
    enabled_for_deployment          = false
    enabled_for_template_deployment = false
    purge_protection_enabled        = false
    soft_delete_retention_days      = 90
    public_network_access_enabled   = true
    network_acls = {
      bypass                     = "AzureServices"
      default_action             = "Allow"
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
