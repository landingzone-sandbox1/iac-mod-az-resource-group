locals {
  # Map Azure location to region_code for Americas (USA, Canada, etc.)
  # Supports both normalized form (eastus2) and long form (East US 2)
  # Uses 3-character region codes to maintain compatibility with child modules
  location_to_region_code = {
    # USA - Normalized forms
    "eastus"              = "EU1"
    "eastus2"             = "EU2"
    "centralus"           = "CU1"
    "northcentralus"      = "NCU"
    "southcentralus"      = "SCU"
    "westus"              = "WU1"
    "westus2"             = "WU2"
    "westus3"             = "WU3"
    "southcentralusstage" = "SCS"

    # USA - Long forms (display names)
    "East US"                = "EU1"
    "East US 2"              = "EU2"
    "Central US"             = "CU1"
    "North Central US"       = "NCU"
    "South Central US"       = "SCU"
    "West US"                = "WU1"
    "West US 2"              = "WU2"
    "West US 3"              = "WU3"
    "South Central US Stage" = "SCS"

    # Canada - Normalized forms
    "canadacentral" = "CC1"
    "canadaeast"    = "CE1"

    # Canada - Long forms
    "Canada Central" = "CC1"
    "Canada East"    = "CE1"

    # Brazil - Normalized forms
    "brazilsouth"     = "BS1"
    "brazilsoutheast" = "BSE"

    # Brazil - Long forms
    "Brazil South"     = "BS1"
    "Brazil Southeast" = "BSE"

    # Mexico - Normalized forms
    "mexicocentral" = "MC1"

    # Mexico - Long forms
    "Mexico Central" = "MC1"

    # Chile - Normalized forms
    "chilecentral" = "CL1"

    # Chile - Long forms
    "Chile Central" = "CL1"
  }


  service_code_rsg = "RSG"
  region_code      = lookup(local.location_to_region_code, var.location, "EUS2")

  # Support both new naming object and legacy individual variables for backward compatibility
  application_code = try(var.naming.application_code)
  environment      = try(var.naming.environment)
  correlative      = try(var.naming.correlative)
  objective_code   = try(var.naming.objective_code)

  name = "${local.service_code_rsg}${local.region_code}${local.application_code}${local.environment}${local.correlative}"

  storage_config = merge(var.storage_config, {
    naming = local.naming
  })

  naming = {
    application_code = local.application_code
    region_code      = local.region_code
    environment      = local.environment
    correlative      = local.correlative
    objective_code   = local.objective_code
  }
}