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
  # tflint-ignore: terraform_module_pinned_source
  source           = "git@github.com:creditcorp/iac-mod-az-log-analytics.git//modules/iac-mod-az-log-analytics"
  location         = var.location
  region_code      = var.region_code
  application_code = var.application_code
  objective_code   = var.objective_code
  environment      = var.environment
  correlative      = var.correlative

  # Optional: pass tags or other variables as needed
  tags = var.tags
}

# add storage account

module "storage_account" {
  # tflint-ignore: terraform_module_pinned_source
  source           = "git@github.com:creditcorp/iac-mod-az-storage-account.git//modules/iac-mod-az-storage-account"
  location         = var.location
  region_code      = var.region_code
  application_code = var.application_code
  objective_code   = var.objective_code
  environment      = var.environment
  correlative      = var.correlative

  # Optional: pass tags or other variables as needed
  tags                             = var.tags
  account_tier                     = var.account_tier
  account_replication_type         = var.account_replication_type
  account_kind                     = var.account_kind
  access_tier                      = var.access_tier
  allow_nested_items_to_be_public  = var.allow_nested_items_to_be_public
  cross_tenant_replication_enabled = var.cross_tenant_replication_enabled
}
