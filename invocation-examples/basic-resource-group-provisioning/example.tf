# Repository: https://github.com/creditcorp/iac-mod-az-resource-group
#
# Use case name: Basic Azure Resource Group Provisioning
# Description: Example of how to provision a Resource Group using the module with validated configuration.
# When to use: Use when you need to create a resource group with standardized naming, tagging, and optional resource lock.
# Considerations:
#   - The resource group name is auto-generated using standard naming logic within the module.
#   - Only user-settable variables are exposed below; internal values are handled via locals.
#   - Optional resource lock and tags can be set as needed.
# Variables sent (user-settable):
#   - location: Azure region for the resource group (non-empty string).
#   - region_code: Short code for the Azure region (uppercase alphanumeric, e.g., "EU2").
#   - application_code: Application identifier for naming and tagging (exactly 4 alphanumeric characters, e.g., "AP01").
#   - environment: Environment code (one of: P, C, D).
#   - correlative: Unique identifier or numeric suffix (non-empty string, e.g., "01").
#   - lock: (Optional) Object to configure a resource lock (kind: "CanNotDelete" or "ReadOnly", name: optional).
#   - tags: (Optional) Map of tags to assign to the resource group.
# Variables not sent (non-user-settable):
#   - service_code: Internal constant for naming, set to "RSG" in the module.
#   - resource_group_name: Auto-generated in the module using locals.

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
  lock = {
    kind = "ReadOnly"
    name = null
  }
  tags = {
    owner = "devops"
    env   = "dev"
  }
}