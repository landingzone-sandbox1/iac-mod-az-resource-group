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
    azurerm_storage_account.this,
    azurerm_log_analytics_workspace.this,
    azurerm_storage_container.this
  ]
}

resource "azurerm_log_analytics_workspace" "this" {
  name                            = local.log_analytics_name
  location                        = azurerm_resource_group.this.location
  resource_group_name             = azurerm_resource_group.this.name
  sku                             = var.log_analytics_sku
  retention_in_days               = var.log_analytics_retention_days
  daily_quota_gb                  = var.log_analytics_daily_quota_gb
  allow_resource_only_permissions = var.log_analytics_workspace_allow_resource_only_permissions
  cmk_for_query_forced            = var.log_analytics_workspace_cmk_for_query_forced
  internet_ingestion_enabled      = var.log_analytics_workspace_internet_ingestion_enabled
  internet_query_enabled          = var.log_analytics_workspace_internet_query_enabled
  local_authentication_disabled   = var.log_analytics_workspace_local_authentication_disabled

  tags = var.tags
}

resource "azurerm_storage_account" "this" {
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  access_tier                     = var.access_tier
  shared_access_key_enabled       = var.shared_access_key_enabled
  public_network_access_enabled   = var.public_network_access_enabled
  default_to_oauth_authentication = true
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"

  dynamic "network_rules" {
    for_each = var.firewall_ips != null || var.vnet_subnet_ids != null ? [1] : []
    content {
      default_action             = "Deny"
      ip_rules                   = var.firewall_ips
      virtual_network_subnet_ids = var.vnet_subnet_ids
      bypass                     = ["AzureServices"]
    }
  }

  blob_properties {
    delete_retention_policy {
      days = var.blob_delete_retention_days
    }
    container_delete_retention_policy {
      days = var.container_delete_retention_days
    }
    versioning_enabled = var.blob_versioning_enabled
  }

  tags = var.tags
}

# Storage Container (optional)
resource "azurerm_storage_container" "this" {
  count                 = var.storage_container != null ? 1 : 0
  name                  = var.storage_container.name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = var.storage_container.container_access_type
}
