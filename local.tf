locals {
  # Map Azure location to region_code for Americas (USA, Canada, etc.)
  location_to_region_code = {
    # USA
    "eastus"              = "EUS"
    "eastus2"             = "EUS2"
    "centralus"           = "CUS"
    "northcentralus"      = "NCUS"
    "southcentralus"      = "SCUS"
    "westus"              = "WUS"
    "westus2"             = "WUS2"
    "westus3"             = "WUS3"
    "southcentralusstage" = "SCUSS"
    # Canada
    "canadacentral" = "CCAN"
    "canadaeast"    = "ECAN"
    # Brazil
    "brazilsouth"     = "BSOU"
    "brazilsoutheast" = "BSE"
    # Mexico
    "mexicocentral" = "MCEN"
    # Chile
    "chilecentral" = "CCEN"
  }


  service_code_rsg = "RSG"
  region_code      = lookup(local.location_to_region_code, var.location, "EUS2")
  application_code = var.application_code
  environment      = var.environment
  correlative      = var.correlative
  name             = "${local.service_code_rsg}${local.region_code}${local.application_code}${local.environment}${local.correlative}"

  naming = {
    application_code = local.application_code
    region_code      = local.region_code
    environment      = local.environment
    correlative      = local.correlative
    objective_code   = var.objective_code
  }
}