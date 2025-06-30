# locals {
#   storage_account_config = {
#     network_and_rbac_settings = var.network_and_rbac_settings
#     storage_container         = var.storage_container
#     naming                    = var.naming
#     storage_settings          = var.storage_settings
#     # cost_management           = var.cost_management

#     # Locally set/internal values (example, add as needed)
#     # some_internal_flag = true
#     # another_internal_value = "fixed-value"
#   }
# }
locals {
  # Resource Group naming
  service_code_rsg = "RSG"
  region_code      = var.region_code
  application_code = var.application_code
  environment      = var.environment
  correlative      = var.correlative
  name             = "${local.service_code_rsg}${local.region_code}${local.application_code}${local.environment}${local.correlative}"

  # # Storage Account naming (must be lowercase and unique)
  # storage_account_name = lower("st${var.objective_code}${local.region_code}${local.application_code}${local.environment}${local.correlative}")

  # # Log Analytics Workspace naming (using dedicated objective code)
  # log_analytics_name = "log-${lower(var.log_analytics_objective_code)}-${lower(local.region_code)}-${lower(local.application_code)}-${lower(local.environment)}-${local.correlative}"
}


