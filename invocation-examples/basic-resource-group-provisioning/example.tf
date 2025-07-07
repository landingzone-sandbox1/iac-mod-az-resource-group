# =============================================================================
# AZURE RESOURCE GROUP MODULE - BASIC EXAMPLE
# =============================================================================
#
# This example demonstrates the modern, clean interface of the resource group 
# module. It creates a resource group with Log Analytics, Storage Account, and 
# Key Vault using standardized naming conventions and security defaults.
#
# Features demonstrated:
# - Credicorp naming conventions for all resources
# - Secure defaults for all services
# - Proper RBAC and access controls
# - Cost management and tagging
# - Infrastructure encryption and monitoring
#
# To use this example:
# 1. Copy this file to your project directory
# 2. Modify the variables to match your environment
# 3. Run: terraform init && terraform plan && terraform apply
#
# =============================================================================

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
  # Use Azure AD authentication for enhanced security
  storage_use_azuread = true
}

# =============================================================================
# MODULE CALL
# =============================================================================

module "resource_group" {
  source = "../../" # Relative path to the root module

  # Core configuration
  location = "East US 2"

  # Naming convention following Credicorp standards
  naming = {
    application_code = "DEMO" # 4-character application code
    environment      = "D"    # D=Development, T=Testing, P=Production, F=Formal
    correlative      = "01"   # Two-digit correlative
    objective_code   = "INFR" # Infrastructure objective code
  }

  # Resource group configuration
  resource_group_config = {
    tags = {
      "Environment" = "Development"
      "Project"     = "Demo Infrastructure"
      "Owner"       = "Infrastructure Team"
      "CreatedBy"   = "Terraform"
      "CostCenter"  = "IT-001"
    }
    # Uncomment to enable resource lock
    # lock = {
    #   kind = "ReadOnly"     # or "CanNotDelete"
    #   name = "infra-lock"
    # }
  }

  # Storage account configuration
  storage_config = {
    # Log Analytics workspace dependency (will be filled by module)
    log_analytics_workspace_id = "" # Filled automatically by module

    # Resource group configuration (use the one created by this module)
    resource_group = {
      create_new = false # Use existing RG created by this module
      name       = null  # Will be filled automatically
    }

    # RBAC role assignments (empty for basic example)
    # For production, add specific role assignments for service principals
    role_assignments = {}

    # Resource tags specific to storage
    tags = {
      "Component"  = "Storage"
      "DataType"   = "Infrastructure"
      "Backup"     = "Enabled"
      "Encryption" = "Enabled"
      "Monitoring" = "Enabled"
    }

    # Data retention settings
    retention_days = 30

    # Resource lock configuration
    # lock = {
    #   kind = "ReadOnly"
    #   name = "storage-lock"
    # }

    # Network security settings
    firewall_ips = [
      "203.0.113.10", # Example corporate IP range
      "203.0.113.20"  # Example VPN gateway IP
    ]
    vnet_subnet_ids = [] # Add subnet resource IDs for VNet integration

    # Diagnostic log categories
    diagnostic_categories = [
      "StorageRead",
      "StorageWrite",
      "StorageDelete"
    ]

    # Storage account performance and replication
    account_replication_type = "LRS"       # Locally redundant storage
    account_tier             = "Standard"  # Standard performance tier
    account_kind             = "StorageV2" # General-purpose v2
    access_tier              = "Hot"       # Hot access tier for frequently accessed data

    # Advanced storage features
    large_file_share_enabled          = false
    is_hns_enabled                    = false # Hierarchical namespace (Data Lake Gen2)
    nfsv3_enabled                     = false
    sftp_enabled                      = false
    queue_encryption_key_type         = "Service" # Microsoft-managed keys
    table_encryption_key_type         = "Service" # Microsoft-managed keys
    infrastructure_encryption_enabled = false     # Double encryption
    blob_versioning_enabled           = true      # Enable blob versioning
    blob_change_feed_enabled          = false     # Change feed for blob events

    # Storage container configuration
    storage_container = {
      name                  = "infrastructure-data"
      container_access_type = "private" # Private access only
    }

    # Customer-managed key configuration (optional)
    # customer_managed_key = {
    #   key_vault_resource_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/..."
    #   key_name              = "storage-encryption-key"
    # }

    # Cross-tenant replication settings
    cross_tenant_replication_enabled = false
    allowed_copy_scope               = "AAD" # Restrict to Azure AD tenant

    # Local user configuration for SFTP (if enabled)
    local_user = {}
  }

  # Key Vault configuration
  key_vault_settings = {
    sku_name                        = "premium" # Premium SKU for hardware security
    enabled_for_disk_encryption     = true      # Allow disk encryption
    enabled_for_deployment          = false     # Disable VM deployment access
    enabled_for_template_deployment = false     # Disable ARM template access
    purge_protection_enabled        = true      # Enable purge protection
    soft_delete_retention_days      = 90        # 90-day retention for deleted keys
    public_network_access_enabled   = false     # Disable public access

    network_acls = {
      bypass         = "AzureServices" # Allow Azure services
      default_action = "Deny"          # Deny all by default
      ip_rules = [
        "203.0.113.1", # Example corporate IP
        "203.0.113.2"  # Example admin workstation IP
      ]
      virtual_network_subnet_ids = [] # Add subnet IDs for VNet access
    }
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "resource_group_name" {
  description = "The name of the created resource group"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "The Azure resource ID of the resource group"
  value       = module.resource_group.resource_group_id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = module.resource_group.log_analytics_workspace_name
}

output "log_analytics_workspace_id" {
  description = "The Azure resource ID of the Log Analytics workspace"
  value       = module.resource_group.log_analytics_workspace_id
}

output "storage_account" {
  description = "Storage account details and configuration"
  value       = module.resource_group.storage_account
  sensitive   = true # Mark as sensitive due to potential access keys
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = module.resource_group.key_vault_name
}

output "key_vault_id" {
  description = "The Azure resource ID of the Key Vault"
  value       = module.resource_group.key_vault_id
}

output "resource_naming_convention" {
  description = "The naming convention used for all resources"
  value = {
    resource_group_name = module.resource_group.resource_group_name
    pattern             = "RSG<region><app_code><env><correlative>"
    application_code    = "DEMO"
    environment         = "D"
    correlative         = "01"
  }
}
