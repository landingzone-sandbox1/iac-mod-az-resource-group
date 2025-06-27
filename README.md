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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/log_analytics_workspace) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/management_lock) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/resource_group) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/storage_account) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/storage_container) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Storage account access tier. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Storage account kind. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Storage account replication type. | `string` | `"ZRS"` | no |
| <a name="input_application_code"></a> [application\_code](#input\_application\_code) | Application code or service code. | `string` | n/a | yes |
| <a name="input_blob_delete_retention_days"></a> [blob\_delete\_retention\_days](#input\_blob\_delete\_retention\_days) | Number of days to retain deleted blobs. | `number` | `7` | no |
| <a name="input_blob_versioning_enabled"></a> [blob\_versioning\_enabled](#input\_blob\_versioning\_enabled) | Enable blob versioning. | `bool` | `true` | no |
| <a name="input_container_delete_retention_days"></a> [container\_delete\_retention\_days](#input\_container\_delete\_retention\_days) | Number of days to retain deleted containers. | `number` | `7` | no |
| <a name="input_correlative"></a> [correlative](#input\_correlative) | Correlative or sequence identifier for the resource group. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Application environment (P, C, D). | `string` | n/a | yes |
| <a name="input_firewall_ips"></a> [firewall\_ips](#input\_firewall\_ips) | List of IP addresses or CIDR blocks to allow access to storage account. | `list(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Required. The Azure region for deployment of the this resource. | `string` | n/a | yes |
| <a name="input_lock"></a> [lock](#input\_lock) | Controls the Resource Lock configuration for this resource. The following properties can be specified:<br/><br/>  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.<br/>  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource. | <pre>object({<br/>    kind = optional(string, "ReadOnly")<br/>    name = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_log_analytics_daily_quota_gb"></a> [log\_analytics\_daily\_quota\_gb](#input\_log\_analytics\_daily\_quota\_gb) | Log Analytics workspace daily quota in GB. | `number` | `-1` | no |
| <a name="input_log_analytics_objective_code"></a> [log\_analytics\_objective\_code](#input\_log\_analytics\_objective\_code) | 3-4 character purpose code for Log Analytics workspace (e.g., MON, LOG). | `string` | `"MON"` | no |
| <a name="input_log_analytics_retention_days"></a> [log\_analytics\_retention\_days](#input\_log\_analytics\_retention\_days) | Log Analytics workspace retention in days. | `number` | `30` | no |
| <a name="input_log_analytics_sku"></a> [log\_analytics\_sku](#input\_log\_analytics\_sku) | Log Analytics workspace SKU. | `string` | `"PerGB2018"` | no |
| <a name="input_log_analytics_workspace_allow_resource_only_permissions"></a> [log\_analytics\_workspace\_allow\_resource\_only\_permissions](#input\_log\_analytics\_workspace\_allow\_resource\_only\_permissions) | Allow resource-only permissions for the Log Analytics workspace. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_cmk_for_query_forced"></a> [log\_analytics\_workspace\_cmk\_for\_query\_forced](#input\_log\_analytics\_workspace\_cmk\_for\_query\_forced) | Require customer-managed key for query operations. | `bool` | `false` | no |
| <a name="input_log_analytics_workspace_internet_ingestion_enabled"></a> [log\_analytics\_workspace\_internet\_ingestion\_enabled](#input\_log\_analytics\_workspace\_internet\_ingestion\_enabled) | Enable ingestion over public internet for the Log Analytics workspace. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_internet_query_enabled"></a> [log\_analytics\_workspace\_internet\_query\_enabled](#input\_log\_analytics\_workspace\_internet\_query\_enabled) | Enable query over public internet for the Log Analytics workspace. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_local_authentication_disabled"></a> [log\_analytics\_workspace\_local\_authentication\_disabled](#input\_log\_analytics\_workspace\_local\_authentication\_disabled) | Disable local authentication (use Azure AD only). | `bool` | `false` | no |
| <a name="input_objective_code"></a> [objective\_code](#input\_objective\_code) | 3-4 character code for resource purpose (e.g., STOR, CORE). | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Enable public network access for storage account. | `bool` | `false` | no |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | Region code (e.g., 'EU2'for EastUS2). | `string` | n/a | yes |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | Enable shared access key for storage account. | `bool` | `false` | no |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | Storage account tier. | `string` | `"Standard"` | no |
| <a name="input_storage_container"></a> [storage\_container](#input\_storage\_container) | Storage container configuration. | <pre>object({<br/>    name                  = string<br/>    container_access_type = optional(string, "private")<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags of the resource. | `map(string)` | `null` | no |
| <a name="input_vnet_subnet_ids"></a> [vnet\_subnet\_ids](#input\_vnet\_subnet\_ids) | List of virtual network subnet IDs to allow access to storage account. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The resource ID of the Log Analytics workspace |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | The name of the Log Analytics workspace |
| <a name="output_log_analytics_workspace_primary_shared_key"></a> [log\_analytics\_workspace\_primary\_shared\_key](#output\_log\_analytics\_workspace\_primary\_shared\_key) | The primary shared key of the Log Analytics workspace |
| <a name="output_log_analytics_workspace_retention_days"></a> [log\_analytics\_workspace\_retention\_days](#output\_log\_analytics\_workspace\_retention\_days) | The retention period in days for the Log Analytics workspace |
| <a name="output_log_analytics_workspace_secondary_shared_key"></a> [log\_analytics\_workspace\_secondary\_shared\_key](#output\_log\_analytics\_workspace\_secondary\_shared\_key) | The secondary shared key of the Log Analytics workspace |
| <a name="output_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#output\_log\_analytics\_workspace\_sku) | The SKU of the Log Analytics workspace |
| <a name="output_log_analytics_workspace_workspace_id"></a> [log\_analytics\_workspace\_workspace\_id](#output\_log\_analytics\_workspace\_workspace\_id) | The workspace ID of the Log Analytics workspace |
| <a name="output_name"></a> [name](#output\_name) | The name of the resource group |
| <a name="output_resource"></a> [resource](#output\_resource) | This is the full output for the resource group. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The resource Id of the resource group |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The resource ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
| <a name="output_storage_account_primary_access_key"></a> [storage\_account\_primary\_access\_key](#output\_storage\_account\_primary\_access\_key) | The primary access key for the storage account |
| <a name="output_storage_account_primary_blob_endpoint"></a> [storage\_account\_primary\_blob\_endpoint](#output\_storage\_account\_primary\_blob\_endpoint) | The primary blob endpoint for the storage account |
| <a name="output_storage_account_primary_connection_string"></a> [storage\_account\_primary\_connection\_string](#output\_storage\_account\_primary\_connection\_string) | The primary connection string for the storage account |
| <a name="output_storage_container_id"></a> [storage\_container\_id](#output\_storage\_container\_id) | The resource ID of the storage container |
| <a name="output_storage_container_name"></a> [storage\_container\_name](#output\_storage\_container\_name) | The name of the storage container |
<!-- END_TF_DOCS -->