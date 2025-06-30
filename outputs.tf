output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "The resource ID of the resource group."
  value       = azurerm_resource_group.this.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace from the module."
  value       = module.log_analytics.log_analytics_workspace_name
}

output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace from the module."
  value       = module.log_analytics.resource_id
}

output "storage_account_name" {
  description = "The name of the storage account from the module."
  value       = module.storage_account.storage_account_name
}

output "storage_account_id" {
  description = "The ID of the storage account from the module."
  value       = module.storage_account.storage_account_id
}

output "storage_container_name" {
  description = "The name of the storage container from the module, if created."
  value       = module.storage_account.storage_container_name
}

output "storage_account" {
  description = "Object containing key storage account outputs."
  value       = module.storage_account.storage_account
}

