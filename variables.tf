variable "location" {
  type        = string
  description = "Required. The Azure region for deployment of the this resource."
  nullable    = false
  validation {
    condition     = length(trim(var.location)) > 0
    error_message = "The location must not be empty."
  }
}

variable "application_code" {
  type        = string
  description = "Application code or service code."
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{4}$", var.application_code))
    error_message = "The application_code must be exactly 4 alphanumeric characters."
  }
}

variable "region_code" {
  type        = string
  description = "Region code (e.g., 'EU2'for EastUS2)."
  nullable    = false
  validation {
    condition     = can(regex("^[A-Z0-9]{2,}$", var.region_code))
    error_message = "The region_code must be uppercase letters and/or numbers (e.g., 'EU2')."
  }
}

variable "environment" {
  type        = string
  description = "Application environment (P, C, D)."
  nullable    = false
  validation {
    condition     = contains(["P", "C", "D"], var.environment)
    error_message = "The environment must be one of: P, C, D."
  }
}

variable "correlative" {
  description = "Correlative or sequence identifier for the resource group."
  type        = string
  validation {
    condition     = length(trim(var.correlative)) > 0
    error_message = "The correlative must not be empty."
  }
}

variable "lock" {
  type = object({
    kind = optional(string, "ReadOnly")
    name = optional(string, null)
  })
  default     = null
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

