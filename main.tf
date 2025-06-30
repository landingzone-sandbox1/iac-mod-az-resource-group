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
    module.log_analytics
  ]
}

# add log analytics module
module "log_analytics" {
  # source = "./child-module-source/iac-mod-az-log-analytics"
  # tflint-ignore: terraform_module_pinned_source
  source           = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-log-analytics"
  location         = var.location
  region_code      = var.region_code
  objective_code   = var.objective_code
  application_code = var.application_code
  environment      = var.environment
  correlative      = var.correlative
  depends_on       = [azurerm_resource_group.this]
  tags             = var.tags
}

# add storage account

module "storage_account" {
  # source = "./child-module-source/iac-mod-az-storage-account"
  # tflint-ignore: terraform_module_pinned_source
  source   = "git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-storage-account"
  location = var.location


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
