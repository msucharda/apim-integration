resource "azurerm_application_insights" "main" {
  name                          = local.resource_names.app_insights
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  workspace_id                  = azurerm_log_analytics_workspace.main.id
  application_type              = "web"
  local_authentication_disabled = true
  tags                          = local.common_tags
}
