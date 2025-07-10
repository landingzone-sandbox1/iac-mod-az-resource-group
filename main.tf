data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = local.name
  tags     = try(var.resource_group_config.tags, {})
}

resource "azurerm_management_lock" "this" {
  count = var.resource_group_config.apply_locks && var.resource_group_config.lock != null ? 1 : 0

  # Microsoft Security Recommendation: Implement Resource Locks
  lock_level = var.resource_group_config.lock.kind
  name       = coalesce(var.resource_group_config.lock.name, "lock-${var.resource_group_config.lock.kind}")
  scope      = azurerm_resource_group.this.id
  notes      = var.resource_group_config.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [
    module.storage_account,
    module.log_analytics,
    module.key_vault
  ]
}

# Log Analytics Workspace Module
# Log Analytics Workspace Module
module "log_analytics" {
  # source = "./child-module-source/iac-mod-az-log-analytics"
  # For production, use: 
  # tflint-ignore: terraform_module_pinned_source
  source = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-log-analytics"

  location = var.location
  naming   = local.naming

  log_analytics_config = merge(var.log_analytics_config, {
    # Resource management (override with actual resource group name)
    resource_group_name = azurerm_resource_group.this.name

    # Merge tags from variable and resource group config
    tags = merge(
      var.log_analytics_config.tags,
      var.resource_group_config.tags
    )
  })

  depends_on = [azurerm_resource_group.this]
}

# Storage Account Module
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

    # Resource management (use existing RG created by this module)
    resource_group = {
      create_new = false
      name       = azurerm_resource_group.this.name
    }

    # Additional tags from resource group config (storage_config already includes its own tags and retention_days)
    tags = merge(var.storage_config.tags, var.resource_group_config.tags)
  })

  depends_on = [azurerm_resource_group.this, module.log_analytics]
}

# Key Vault Module
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
    sku_name                        = local.key_vault_settings.sku_name
    enabled_for_disk_encryption     = local.key_vault_settings.enabled_for_disk_encryption
    enabled_for_deployment          = local.key_vault_settings.enabled_for_deployment
    enabled_for_template_deployment = local.key_vault_settings.enabled_for_template_deployment
    purge_protection_enabled        = local.key_vault_settings.purge_protection_enabled
    soft_delete_retention_days      = local.key_vault_settings.soft_delete_retention_days
    public_network_access_enabled   = local.key_vault_settings.public_network_access_enabled

    # Network access control
    network_acls = local.key_vault_settings.network_acls

    # Resource management
    resource_group_name = azurerm_resource_group.this.name
    lock                = var.resource_group_config.lock

    # RBAC and tagging
    role_assignments = local.storage_config.role_assignments
    tags             = var.resource_group_config.tags
  }

  depends_on = [azurerm_resource_group.this]
}