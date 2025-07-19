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

  # Use naming fields directly (no fallbacks)
  application_code = var.naming.application_code
  environment      = var.naming.environment
  correlative      = var.naming.correlative
  objective_code   = var.naming.objective_code

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

  # Set SKU for Key Vault based on environment
  # Premium for Production, Standard for others
  keyvault_sku_name = upper(local.environment) == "P" ? "premium" : "standard"

  # Create keyvault_config object for the Key Vault module
  keyvault_config = merge(var.keyvault_config, {
    # Environment-based SKU selection (overrides variable default)
    sku_name = local.keyvault_sku_name

    # Required tenant ID
    tenant_id = data.azurerm_client_config.current.tenant_id

    # Resource management (will be overridden in main.tf)
    resource_group_name = {
      create_new = false
      name       = null # Will be set in main.tf
    }
    lock = null # Will be set in main.tf

    # RBAC and tagging (will be merged in main.tf)
    role_assignments = {}

    diagnostic_settings = {
      # Ensure at least one diagnostic setting is configured for security compliance
      enabled = true
      logs = [
        {
          category = "AuditEvent"
          enabled  = true
        }
      ]
      metrics = [
        {
          category = "AllMetrics"
          enabled  = true
        }
      ]
    }
  })
}