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
}
