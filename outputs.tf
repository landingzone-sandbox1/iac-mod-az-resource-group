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

output "storage_account" {
  description = "Object containing key storage account outputs."
  value       = module.storage_account.storage_account
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = module.key_vault.name
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault."
  value       = module.key_vault.id
}

output "key_vault_resource" {
  description = "The complete Azure Key Vault resource object"
  value       = module.key_vault
}

