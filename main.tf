resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "${local.service_code_rsg}-CU2-${var.application_code}-${var.environment}"
  tags     = var.tags
}

# required AVM resources interfaces
#resource "azurerm_management_lock" "this" {
#  count = var.lock != null ? 1 : 0
#
#  lock_level = var.lock.kind
#  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
#  scope      = azurerm_resource_group.this.id
#  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
#}
