output "name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "resource" {
  description = "This is the full output for the resource group."
  value       = azurerm_resource_group.this
}

output "resource_id" {
  description = "The resource Id of the resource group"
  value       = azurerm_resource_group.this.id
}

# Storage Account Outputs
output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "storage_account_id" {
  description = "The resource ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "storage_account_primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint for the storage account"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

# Log Analytics Workspace Outputs (per usage guide)
output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_workspace_id" {
  description = "The workspace ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "log_analytics_workspace_primary_shared_key" {
  description = "The primary shared key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_secondary_shared_key" {
  description = "The secondary shared key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.secondary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_sku" {
  description = "The SKU of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.sku
}

output "log_analytics_workspace_retention_days" {
  description = "The retention period in days for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.retention_in_days
}

# Storage Container Outputs (conditional)
output "storage_container_name" {
  description = "The name of the storage container"
  value       = var.storage_container != null ? azurerm_storage_container.this[0].name : null
}

output "storage_container_id" {
  description = "The resource ID of the storage container"
  value       = var.storage_container != null ? azurerm_storage_container.this[0].id : null
}
