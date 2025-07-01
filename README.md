<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.28 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.28 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-key-vault.git | n/a |
| <a name="module_log_analytics"></a> [log\_analytics](#module\_log\_analytics) | git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-log-analytics | n/a |
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | git::ssh://git@github.com/landingzone-sandbox/iac-mod-az-storage-account | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/management_lock) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_code"></a> [application\_code](#input\_application\_code) | Application code or service code. | `string` | n/a | yes |
| <a name="input_correlative"></a> [correlative](#input\_correlative) | Correlative or sequence identifier for the resource group. | `string` | n/a | yes |
| <a name="input_cost_management"></a> [cost\_management](#input\_cost\_management) | Cost management and tagging settings. | <pre>object({<br/>    tags           = map(string)<br/>    retention_days = number<br/>  })</pre> | <pre>{<br/>  "retention_days": 14,<br/>  "tags": {}<br/>}</pre> | no |
| <a name="input_diagnostic_categories"></a> [diagnostic\_categories](#input\_diagnostic\_categories) | List of diagnostic log categories to enable for the storage account. | `list(string)` | <pre>[<br/>  "StorageRead",<br/>  "StorageWrite",<br/>  "StorageDelete"<br/>]</pre> | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings for the storage account. | <pre>object({<br/>    enable_blob                = bool<br/>    enable_queue               = bool<br/>    enable_table               = bool<br/>    enable_file                = bool<br/>    enable_account             = bool<br/>    log_analytics_workspace_id = string<br/>  })</pre> | <pre>{<br/>  "enable_account": true,<br/>  "enable_blob": true,<br/>  "enable_file": false,<br/>  "enable_queue": false,<br/>  "enable_table": false,<br/>  "log_analytics_workspace_id": ""<br/>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Application environment (P, C, D, F). | `string` | n/a | yes |
| <a name="input_key_vault_settings"></a> [key\_vault\_settings](#input\_key\_vault\_settings) | Configuration settings for the Key Vault. | <pre>object({<br/>    sku_name                        = string<br/>    enabled_for_disk_encryption     = bool<br/>    enabled_for_deployment          = bool<br/>    enabled_for_template_deployment = bool<br/>    purge_protection_enabled        = bool<br/>    soft_delete_retention_days      = number<br/>    public_network_access_enabled   = bool<br/>    network_acls = object({<br/>      bypass                     = string<br/>      default_action             = string<br/>      ip_rules                   = list(string)<br/>      virtual_network_subnet_ids = list(string)<br/>    })<br/>  })</pre> | <pre>{<br/>  "enabled_for_deployment": false,<br/>  "enabled_for_disk_encryption": true,<br/>  "enabled_for_template_deployment": false,<br/>  "network_acls": {<br/>    "bypass": "AzureServices",<br/>    "default_action": "Deny",<br/>    "ip_rules": [],<br/>    "virtual_network_subnet_ids": []<br/>  },<br/>  "public_network_access_enabled": false,<br/>  "purge_protection_enabled": true,<br/>  "sku_name": "premium",<br/>  "soft_delete_retention_days": 90<br/>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | Required. The Azure region for deployment of the this resource. | `string` | n/a | yes |
| <a name="input_lock"></a> [lock](#input\_lock) | Controls the Resource Lock configuration for this resource. The following properties can be specified:<br/><br/>  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.<br/>  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource. | <pre>object({<br/>    kind = optional(string, "ReadOnly")<br/>    name = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_naming"></a> [naming](#input\_naming) | Naming convention object for resource naming. | <pre>object({<br/>    application_code = string # 4 alphanumeric characters<br/>    region_code      = string # e.g., 'EU2'<br/>    environment      = string # P, C, D, F<br/>    correlative      = string # sequence identifier<br/>    objective_code   = string # 3-4 uppercase alphanumeric characters<br/>  })</pre> | n/a | yes |
| <a name="input_network_and_rbac_settings"></a> [network\_and\_rbac\_settings](#input\_network\_and\_rbac\_settings) | Network and RBAC configuration for the storage account. | <pre>object({<br/>    firewall_ips    = optional(list(string), [])<br/>    vnet_subnet_ids = optional(list(string), [])<br/>    role_assignments = optional(map(object({<br/>      role_definition_id_or_name             = string<br/>      principal_id                           = string<br/>      principal_type                         = string<br/>      description                            = optional(string, null)<br/>      skip_service_principal_aad_check       = optional(bool, false)<br/>      condition                              = optional(string, null)<br/>      condition_version                      = optional(string, null)<br/>      delegated_managed_identity_resource_id = optional(string, null)<br/>    })), {})<br/>  })</pre> | `{}` | no |
| <a name="input_objective_code"></a> [objective\_code](#input\_objective\_code) | A 3 to 4 character code conveying a meaningful purpose for the resource (e.g., core, mgmt). | `string` | n/a | yes |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | Region code (e.g., 'EU2'for EastUS2). | `string` | n/a | yes |
| <a name="input_storage_container"></a> [storage\_container](#input\_storage\_container) | Configuration for the storage container. Set to null to skip container creation. | <pre>object({<br/>    name                  = string<br/>    container_access_type = optional(string, "private")<br/>  })</pre> | `null` | no |
| <a name="input_storage_settings"></a> [storage\_settings](#input\_storage\_settings) | General storage account settings. | <pre>object({<br/>    account_replication_type          = string<br/>    account_tier                      = string<br/>    account_kind                      = string<br/>    access_tier                       = string<br/>    large_file_share_enabled          = bool<br/>    is_hns_enabled                    = bool<br/>    nfsv3_enabled                     = bool<br/>    sftp_enabled                      = bool<br/>    queue_encryption_key_type         = string<br/>    table_encryption_key_type         = string<br/>    infrastructure_encryption_enabled = bool<br/>    blob_versioning_enabled           = optional(bool, false)<br/>    blob_change_feed_enabled          = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "access_tier": "Hot",<br/>  "account_kind": "StorageV2",<br/>  "account_replication_type": "LRS",<br/>  "account_tier": "Standard",<br/>  "blob_change_feed_enabled": false,<br/>  "blob_versioning_enabled": false,<br/>  "infrastructure_encryption_enabled": false,<br/>  "is_hns_enabled": false,<br/>  "large_file_share_enabled": false,<br/>  "nfsv3_enabled": false,<br/>  "queue_encryption_key_type": "Service",<br/>  "sftp_enabled": false,<br/>  "table_encryption_key_type": "Service"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags of the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The resource ID of the Key Vault. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault. |
| <a name="output_key_vault_resource"></a> [key\_vault\_resource](#output\_key\_vault\_resource) | The complete Azure Key Vault resource object |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The resource ID of the Log Analytics workspace from the module. |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | The name of the Log Analytics workspace from the module. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The resource ID of the resource group. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group. |
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | Object containing key storage account outputs. |
<!-- END_TF_DOCS -->