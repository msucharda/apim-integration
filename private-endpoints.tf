# ------------------------------------------------------------------------------
# APIM Private Endpoint
# ------------------------------------------------------------------------------

resource "azurerm_private_endpoint" "apim" {
  name                = "pe-apim-${local.name_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.pe.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-apim"
    private_connection_resource_id = azurerm_api_management.main.id
    is_manual_connection           = false
    subresource_names              = ["Gateway"]
  }

  private_dns_zone_group {
    name                 = "dns-zone-group-apim"
    private_dns_zone_ids = [var.private_dns_zone_apim_id]
  }
}
