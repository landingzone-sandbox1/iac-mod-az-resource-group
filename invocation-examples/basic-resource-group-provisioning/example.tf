# Example: Basic Azure Resource Group with Storage and Analytics Provisioning
#
# This example provisions a Resource Group, Storage Account, and Log Analytics using the module.
#
# Variables:
#   - location: (string, required) Azure region for the resource group (e.g., "eastus2").
#   - naming: (object, required) Naming convention object with:
#       - application_code: (string, required) Application identifier (exactly 4 alphanumeric characters, e.g., "AP01").
#       - region_code: (string, required) Short code for the Azure region (uppercase alphanumeric, e.g., "EU2").
#       - objective_code: (string, required) Purpose code for storage naming (3-4 uppercase alphanumeric chars, e.g., "CORE").
#       - environment: (string, required) Environment code (one of: P, C, D, F).
#       - correlative: (string, required) Unique identifier or numeric suffix (non-empty string, e.g., "01").
#   - tags: (map(string), optional) Map of tags to assign to resources.
#   - network_and_rbac_settings: (object, required) Network and RBAC settings for storage account.
#   - storage_container: (object, required) Storage container configuration.
#   - diagnostic_categories: (list(string), required) Diagnostic log categories for storage account.
#   - diagnostic_settings: (object, required) Diagnostic settings for storage account.
#   - storage_settings: (object, required) General storage account settings.
#   - cost_management: (object, required) Cost management and tagging settings.
#   - The individual naming variables are also passed for compatibility with modules that require them as separate inputs.


terraform {
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

variable "region_code" {
  description = "Short code for the Azure region (uppercase alphanumeric, e.g., 'EU2')."
  type        = string
  default     = "EU2"
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
  source                   = "../.." # Adjust path as needed
  location                 = local.location
  naming                   = local.naming
  tags                     = local.tags
  network_and_rbac_settings = local.network_and_rbac_settings
  storage_container         = local.storage_container
  diagnostic_categories     = local.diagnostic_categories
  diagnostic_settings       = local.diagnostic_settings
  storage_settings          = local.storage_settings
  cost_management           = local.cost_management
  # Pass naming components individually for modules that require them
  application_code = var.application_code
  region_code      = var.region_code
  objective_code   = var.objective_code
  environment      = var.environment
  correlative      = var.correlative
}

locals {
  location = var.location
  naming = {
    application_code = var.application_code
    region_code      = var.region_code
    environment      = var.environment
    correlative      = var.correlative
    objective_code   = var.objective_code
  }
  tags = var.tags
  network_and_rbac_settings = {} # Fill as needed
  storage_container = {
    name = "default"
  }
  diagnostic_categories = ["StorageRead", "StorageWrite", "StorageDelete"]
  diagnostic_settings = {
    enable_blob                = true
    enable_queue               = false
    enable_table               = false
    enable_file                = false
    enable_account             = true
    log_analytics_workspace_id = ""
  }
  storage_settings = {
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
  cost_management = {
    tags = {}
    retention_days = 14
  }
}
