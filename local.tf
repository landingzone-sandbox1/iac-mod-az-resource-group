locals {
  # Resource Group naming
  service_code_rsg = "RSG"
  region_code      = var.region_code
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