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
| <a name="module_log_analytics"></a> [log\_analytics](#module\_log\_analytics) | git@github.com:creditcorp/iac-mod-az-log-analytics.git//modules/iac-mod-az-log-analytics | n/a |
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | git@github.com:creditcorp/iac-mod-az-storage-account.git//modules/iac-mod-az-storage-account | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/management_lock) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Storage account access tier. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Storage account kind. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Storage account replication type. | `string` | `"ZRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | (Optional) Defines the Tier to use for this storage account. Valid options are 'Standard' and 'Premium'. | `string` | `null` | no |
| <a name="input_allow_nested_items_to_be_public"></a> [allow\_nested\_items\_to\_be\_public](#input\_allow\_nested\_items\_to\_be\_public) | (Optional) Allow or disallow nested items within this Account to opt into being public. Defaults to false. | `bool` | `null` | no |
| <a name="input_application_code"></a> [application\_code](#input\_application\_code) | Application code or service code. | `string` | n/a | yes |
| <a name="input_correlative"></a> [correlative](#input\_correlative) | Correlative or sequence identifier for the resource group. | `string` | n/a | yes |
| <a name="input_cross_tenant_replication_enabled"></a> [cross\_tenant\_replication\_enabled](#input\_cross\_tenant\_replication\_enabled) | (Optional) Should cross Tenant replication be enabled? Defaults to false. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Application environment (P, C, D). | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Required. The Azure region for deployment of the this resource. | `string` | n/a | yes |
| <a name="input_lock"></a> [lock](#input\_lock) | Controls the Resource Lock configuration for this resource. The following properties can be specified:<br/><br/>  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.<br/>  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource. | <pre>object({<br/>    kind = optional(string, "ReadOnly")<br/>    name = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_objective_code"></a> [objective\_code](#input\_objective\_code) | 3-4 character code for resource purpose (e.g., STOR, CORE). | `string` | n/a | yes |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | Region code (e.g., 'EU2'for EastUS2). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags of the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The resource ID of the Log Analytics workspace from the module. |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | The name of the Log Analytics workspace from the module. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The resource ID of the resource group. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account from the module. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account from the module. |
| <a name="output_storage_container_name"></a> [storage\_container\_name](#output\_storage\_container\_name) | The name of the storage container from the module, if created. |
<!-- END_TF_DOCS -->