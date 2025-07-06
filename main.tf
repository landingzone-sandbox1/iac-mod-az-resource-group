data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = local.name
  tags     = var.tags
}
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0
  # Microsoft Security Recommendation: Implement Resource Locks
  lock_level = var.lock.kind
  name       = coalesce(try(var.lock.name, null), "lock-${var.lock.kind}")
  scope      = azurerm_resource_group.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [
    module.storage_account,
    module.log_analytics,
    module.key_vault
  ]
}

# Log Analytics Workspace Module
module "log_analytics" {
  # source = "./child-module-source/iac-mod-az-log-analytics"
  # For production, use: 
  # tflint-ignore: terraform_module_pinned_source
  source = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-log-analytics"

  location = var.location
  naming   = local.naming

  log_analytics_config = {
    # Security settings - enforce secure defaults
    allow_resource_only_permissions = false
    cmk_for_query_forced            = false
    internet_ingestion_enabled      = false
    internet_query_enabled          = false

    # RBAC and tagging
    role_assignments = local.storage_config.role_assignments
    tags             = var.tags
  }

  depends_on = [azurerm_resource_group.this]
}

# Storage Account Module
module "storage_account" {
  # source = "./child-module-source/iac-mod-az-storage-account"
  # For production, use:
  # tflint-ignore: terraform_module_pinned_source
  source = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-storage-account"

  location = var.location
  naming   = local.naming

  # Storage configuration object
  storage_config = merge(local.storage_config, {
    # Infrastructure dependencies
    log_analytics_workspace_id = module.log_analytics.resource_id
    diagnostic_categories      = var.diagnostic_categories

    # Resource management (use existing RG created by this module)
    resource_group = {
      create_new = false
      name       = azurerm_resource_group.this.name
    }

    # Tagging and cost management
    tags           = merge(var.tags, var.cost_management.tags)
    retention_days = var.cost_management.retention_days
  })

  depends_on = [azurerm_resource_group.this, module.log_analytics]
}

# Key Vault Module
module "key_vault" {
  # source = "./child-module-source/iac-mod-az-key-vault"
  # For production, use:
  # tflint-ignore: terraform_module_pinned_source
  source = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-key-vault.git"

  location = var.location
  naming   = local.naming

  keyvault_config = {
    # Required tenant ID
    tenant_id = data.azurerm_client_config.current.tenant_id

    # Security settings from variables
    sku_name                        = var.key_vault_settings.sku_name
    enabled_for_disk_encryption     = var.key_vault_settings.enabled_for_disk_encryption
    enabled_for_deployment          = var.key_vault_settings.enabled_for_deployment
    enabled_for_template_deployment = var.key_vault_settings.enabled_for_template_deployment
    purge_protection_enabled        = var.key_vault_settings.purge_protection_enabled
    soft_delete_retention_days      = var.key_vault_settings.soft_delete_retention_days
    public_network_access_enabled   = var.key_vault_settings.public_network_access_enabled

    # Network access control
    network_acls = var.key_vault_settings.network_acls

    # Resource management
    resource_group_name = azurerm_resource_group.this.name
    lock                = var.lock

    # RBAC and tagging
    role_assignments = local.storage_config.role_assignments
    tags             = var.tags
  }

  depends_on = [azurerm_resource_group.this]
}