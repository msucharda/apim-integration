# ------------------------------------------------------------------------------
# APIM Diagnostic Settings
# ------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "apim" {
  name                       = "diag-apim-to-law"
  target_resource_id         = azurerm_api_management.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "GatewayLogs"
  }

  enabled_log {
    category = "WebSocketConnectionLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
