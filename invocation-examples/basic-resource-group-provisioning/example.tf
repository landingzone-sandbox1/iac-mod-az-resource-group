
# Example: Basic Azure Resource Group with Storage and Analytics Provisioning
#
# This example provisions a Resource Group, Storage Account, and Log Analytics using the module.
#
# Variables:
#   - location: (string, required) Azure region for the resource group (e.g., "eastus2").
#   - region_code: (string, required) Short code for the Azure region (uppercase alphanumeric, e.g., "EU2").
#   - application_code: (string, required) Application identifier (exactly 4 alphanumeric characters, e.g., "AP01").
#   - objective_code: (string, required) Purpose code for storage naming (3-4 uppercase alphanumeric chars, e.g., "CORE").
#   - environment: (string, required) Environment code (one of: P, C, D, F).
#   - correlative: (string, required) Unique identifier or numeric suffix (non-empty string, e.g., "01").
#   - account_replication_type: (string, optional) Storage replication strategy (e.g., "ZRS").
#   - tags: (map(string), optional) Map of tags to assign to resources.
#   - storage_container: (object, optional) Container configuration.
#   - lock: (object, optional) Resource lock configuration.


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
  source             = "../.." # Adjust path as needed
  location           = var.location
  region_code        = var.region_code
  application_code   = var.application_code
  objective_code     = var.objective_code
  environment        = var.environment
  correlative        = var.correlative
  tags               = var.tags
  # account_replication_type = var.account_replication_type # Uncomment and define if needed
  # storage_container        = var.storage_container        # Uncomment and define if needed
  # lock                    = var.lock                    # Uncomment and define if needed
}
