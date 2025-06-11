variable "location" {
  type        = string
  description = "Required. The Azure region for deployment of the this resource."
  nullable    = false
}

variable "application_code" {
  type        = string
  description = "Required. Application code or service code."
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Required. Application environment (P, C, D, F, E)."
  nullable    = false
}
variable "region_code" {
  type        = string
  description = "Region code (e.g., 'EU2'for EastUS2)."
  nullable    = false
}

variable "lock" {
  type = object({
    kind = optional(string, "ReadOnly")
    name = optional(string, null)
  })
  default = {
    kind = "ReadOnly"
    name = null
  }
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:
  
  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "correlative" {
  description = "Correlative or sequence identifier for the resource group."
  type        = string
}