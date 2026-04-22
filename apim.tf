# ------------------------------------------------------------------------------
# API Management
# ------------------------------------------------------------------------------

resource "azurerm_api_management" "main" {
  name                          = local.resource_names.apim
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  publisher_name                = var.apim_publisher_name
  publisher_email               = var.apim_publisher_email
  sku_name                      = "${var.apim_sku}_${var.apim_capacity}"
  min_api_version               = "2021-08-01"
  virtual_network_type          = "External"
  public_network_access_enabled = true

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }

  security {
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled          = false
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled       = false
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled       = false
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled          = false
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled       = false
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled    = false
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled    = false
    triple_des_ciphers_enabled                           = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# APIM Application Insights Logger
# ------------------------------------------------------------------------------

resource "azurerm_api_management_logger" "app_insights" {
  name                = "app-insights-logger"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = azurerm_resource_group.main.name
  resource_id         = azurerm_application_insights.main.id

  application_insights {
    instrumentation_key = azurerm_application_insights.main.instrumentation_key
  }
}
