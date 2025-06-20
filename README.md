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
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/management_lock) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.28/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_code"></a> [application\_code](#input\_application\_code) | Application code or service code. | `string` | n/a | yes |
| <a name="input_correlative"></a> [correlative](#input\_correlative) | Correlative or sequence identifier for the resource group. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Application environment (P, C, D). | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Required. The Azure region for deployment of the this resource. | `string` | n/a | yes |
| <a name="input_lock"></a> [lock](#input\_lock) | Controls the Resource Lock configuration for this resource. The following properties can be specified:<br/><br/>  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.<br/>  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource. | <pre>object({<br/>    kind = optional(string, "ReadOnly")<br/>    name = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | Region code (e.g., 'EU2'for EastUS2). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags of the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | The name of the resource group |
| <a name="output_resource"></a> [resource](#output\_resource) | This is the full output for the resource group. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The resource Id of the resource group |
<!-- END_TF_DOCS -->