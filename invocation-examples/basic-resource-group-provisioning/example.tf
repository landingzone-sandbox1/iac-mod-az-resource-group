# Repository: https://github.com/creditcorp/iac-mod-az-resource-group
#
# Use case name: Basic Azure Resource Group with Storage and Analytics Provisioning
# Description: Example of how to provision a Resource Group with Storage Account and Log Analytics using the module.
# When to use: Use when you need to create a complete environment with storage, logging, and standardized naming.
# Considerations:
#   - The resource names are auto-generated using ALZ naming conventions within the module.
#   - Security defaults are applied (TLS 1.2, OAuth authentication, disabled shared keys).
#   - Optional storage container and resource lock can be configured as needed.
# Variables sent (user-settable):
#   - location: Azure region for the resource group (non-empty string).
#   - region_code: Short code for the Azure region (uppercase alphanumeric, e.g., "EU2").
#   - application_code: Application identifier (exactly 4 alphanumeric characters, e.g., "AP01").
#   - environment: Environment code (one of: P, C, D).
#   - correlative: Unique identifier or numeric suffix (non-empty string, e.g., "01").
#   - objective_code: Purpose code for storage naming (3-4 chars, e.g., "STOR").
#   - account_replication_type: Storage replication strategy.
#   - storage_container: (Optional) Container configuration.
#   - lock: (Optional) Object to configure a resource lock.
#   - tags: (Optional) Map of tags to assign to resources.

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

module "resource_group" {
  source           = "../.." # Adjust path as needed
  location         = "eastus2"
  region_code      = "EU2"
  application_code = "AP01"
  environment      = "D"
  correlative      = "01"
  objective_code   = "STOR"

  # Log Analytics specific objective code (per usage guide)
  log_analytics_objective_code = "MON"

  # Storage Account configuration
  account_replication_type = "ZRS"
  storage_account_tier     = "Standard"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Security settings (recommended for dev)
  shared_access_key_enabled     = true # Set to false for production
  public_network_access_enabled = false

  # Optional storage container
  storage_container = {
    name                  = "data"
    container_access_type = "private"
  }

  # Log Analytics configuration (per usage guide)
  log_analytics_sku                                       = "PerGB2018"
  log_analytics_retention_days                            = 30
  log_analytics_workspace_allow_resource_only_permissions = true
  log_analytics_workspace_internet_ingestion_enabled      = true
  log_analytics_workspace_internet_query_enabled          = true

  # Resource protection
  lock = {
    kind = "ReadOnly"
    name = null
  }

  # Tags for governance (per usage guide)
  tags = {
    owner       = "devops"
    environment = "dev"
    project     = "analytics"
    cost_center = "IT"
  }
}
