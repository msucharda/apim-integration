locals {
  region_short = lookup({
    "westeurope"    = "we"
    "northeurope"   = "ne"
    "swedencentral" = "sc"
    "eastus"        = "eus"
    "eastus2"       = "eus2"
    "westus"        = "wus"
    "westus2"       = "wus2"
  }, var.location, substr(var.location, 0, 4))

  name_suffix = "${var.prefix}-${var.environment}-${local.region_short}"

  resource_names = {
    resource_group = "rg-${local.name_suffix}"
    vnet           = "vnet-${local.name_suffix}"
    log_analytics  = "law-${local.name_suffix}"
    app_insights   = "ai-${local.name_suffix}"
    apim           = "apim-${local.name_suffix}"
  }

  common_tags = merge({
    environment = var.environment
    project     = var.prefix
    managed_by  = "terraform"
  }, var.tags)
}
