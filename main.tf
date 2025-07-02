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

# add log analytics module
module "log_analytics" {
  #  source = "./child-module-source/iac-mod-az-log-analytics"
  # tflint-ignore: terraform_module_pinned_source
  source              = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-log-analytics"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  region_code         = var.region_code
  objective_code      = var.objective_code
  application_code    = var.application_code
  environment         = var.environment
  correlative         = var.correlative
  depends_on          = [azurerm_resource_group.this]
  tags                = var.tags
}

# add storage account

module "storage_account" {
  #  source = "./child-module-source/iac-mod-az-storage-account"
  # tflint-ignore: terraform_module_pinned_source
  source              = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-storage-account"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  # Pass object variables
  naming                    = var.naming
  network_and_rbac_settings = var.network_and_rbac_settings
  storage_container         = var.storage_container
  diagnostic_categories     = var.diagnostic_categories
  diagnostic_settings       = var.diagnostic_settings
  storage_settings          = var.storage_settings
  cost_management           = var.cost_management

  depends_on = [azurerm_resource_group.this]
}

module "key_vault" {
  #  source = "./child-module-source/iac-mod-az-key-vault"
  # tflint-ignore: terraform_module_pinned_source
  source           = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-key-vault.git"
  location         = var.location
  tenant_id        = data.azurerm_client_config.current.tenant_id
  region_code      = var.region_code
  application_code = var.application_code
  objective_code   = var.objective_code
  environment      = var.environment
  correlative      = var.correlative
  tags             = var.tags

  # Key Vault specific settings
  sku_name                        = var.key_vault_settings.sku_name
  enabled_for_disk_encryption     = var.key_vault_settings.enabled_for_disk_encryption
  enabled_for_deployment          = var.key_vault_settings.enabled_for_deployment
  enabled_for_template_deployment = var.key_vault_settings.enabled_for_template_deployment
  purge_protection_enabled        = var.key_vault_settings.purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_settings.soft_delete_retention_days
  public_network_access_enabled   = var.key_vault_settings.public_network_access_enabled
  network_acls                    = var.key_vault_settings.network_acls

  depends_on = [azurerm_resource_group.this]
}