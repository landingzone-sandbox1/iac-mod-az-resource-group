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
| <a name="input_fallback_application_code"></a> [fallback\_application\_code](#input\_fallback\_application\_code) | Fallback application code when naming.application\_code is null. Must be exactly 4 alphanumeric characters. | `string` | `"DEMO"` | no |
| <a name="input_fallback_correlative"></a> [fallback\_correlative](#input\_fallback\_correlative) | Fallback correlative when naming.correlative is null. Must be a two-digit string. | `string` | `"01"` | no |
| <a name="input_fallback_environment"></a> [fallback\_environment](#input\_fallback\_environment) | Fallback environment when naming.environment is null. Must be one of: D, C, P, F. | `string` | `"D"` | no |
| <a name="input_fallback_objective_code"></a> [fallback\_objective\_code](#input\_fallback\_objective\_code) | Fallback objective code when naming.objective\_code is empty. Must be 3 or 4 alphanumeric characters. | `string` | `""` | no |
| <a name="input_keyvault_config"></a> [keyvault\_config](#input\_keyvault\_config) | Configuration settings for the Key Vault. | <pre>object({<br/>    sku_name                        = optional(string, "standard")<br/>    enabled_for_disk_encryption     = optional(bool, true)<br/>    enabled_for_deployment          = optional(bool, false)<br/>    enabled_for_template_deployment = optional(bool, false)<br/>    purge_protection_enabled        = optional(bool, true)<br/>    soft_delete_retention_days      = optional(number, 90)<br/>    public_network_access_enabled   = optional(bool, false)<br/>    network_acls = optional(object({<br/>      bypass                     = optional(string, "AzureServices")<br/>      default_action             = optional(string, "Deny")<br/>      ip_rules                   = optional(list(string), [])<br/>      virtual_network_subnet_ids = optional(list(string), [])<br/>      }), {<br/>      bypass                     = "AzureServices"<br/>      default_action             = "Deny"<br/>      ip_rules                   = []<br/>      virtual_network_subnet_ids = []<br/>    })<br/>    tags = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Required. The Azure region for deployment of this resource. Supports both normalized form (e.g., 'eastus2') and display name form (e.g., 'East US 2'). | `string` | n/a | yes |
| <a name="input_log_analytics_config"></a> [log\_analytics\_config](#input\_log\_analytics\_config) | Configuration object for the Log Analytics workspace module. | <pre>object({<br/>    # Workspace permissions and security<br/>    allow_resource_only_permissions = optional(bool, false)<br/>    cmk_for_query_forced            = optional(bool, false)<br/>    internet_ingestion_enabled      = optional(bool, false)<br/>    internet_query_enabled          = optional(bool, false)<br/><br/>    # Resource tags<br/>    tags = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_naming"></a> [naming](#input\_naming) | Naming convention settings for all resources following Credicorp standards. All fields are optional to allow workspace-specific overrides. | <pre>object({<br/>    application_code = optional(string, null)<br/>    environment      = optional(string, null)<br/>    correlative      = optional(string, null)<br/>    objective_code   = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "application_code": null,<br/>  "correlative": null,<br/>  "environment": null,<br/>  "objective_code": ""<br/>}</pre> | no |
| <a name="input_resource_group_config"></a> [resource\_group\_config](#input\_resource\_group\_config) | Configuration settings for the resource group. | <pre>object({<br/>    tags        = optional(map(string), {})<br/>    apply_locks = optional(bool, false)<br/>    lock = optional(object({<br/>      kind = string<br/>      name = optional(string, null)<br/>    }), null)<br/>  })</pre> | <pre>{<br/>  "apply_locks": false,<br/>  "lock": null,<br/>  "tags": {}<br/>}</pre> | no |
| <a name="input_storage_config"></a> [storage\_config](#input\_storage\_config) | Configuration object for the storage account module. | <pre>object({<br/>    # Required infrastructure settings (provided by orchestration)<br/>    log_analytics_workspace_id = optional(string, null)<br/><br/>    # Resource Group configuration (provided by orchestration)<br/>    resource_group = optional(object({<br/>      create_new = bool<br/>      name       = optional(string, null)<br/>    }), null)<br/><br/>    # RBAC role assignments<br/>    role_assignments = optional(map(object({<br/>      role_definition_id_or_name             = string<br/>      principal_id                           = string<br/>      principal_type                         = string<br/>      description                            = optional(string, null)<br/>      skip_service_principal_aad_check       = optional(bool, false)<br/>      condition                              = optional(string, null)<br/>      condition_version                      = optional(string, null)<br/>      delegated_managed_identity_resource_id = optional(string, null)<br/>    })), {})<br/><br/>    # Resource tags and retention<br/>    tags           = optional(map(string), {})<br/>    retention_days = optional(number, 14)<br/><br/>    # Security settings - Allow override for deployment flexibility<br/>    shared_access_key_enabled = optional(bool, false) # Default false for security, but configurable for deployment needs<br/><br/>    # Deployment lifecycle settings<br/>    enable_deployment_mode = optional(bool, false) # Temporarily relaxes security for initial deployment<br/>  })</pre> | `{}` | no |

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