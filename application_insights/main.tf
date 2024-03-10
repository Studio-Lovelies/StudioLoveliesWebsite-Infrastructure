resource "azurerm_log_analytics_workspace" "ws_sl_prod" {
  name                = "ws-sl-prod"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "ai_sl_prod" {
  name                = "ai-sl-prod"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  application_type    = "web"
  sampling_percentage = 0
  workspace_id        = azurerm_log_analytics_workspace.ws_sl_prod.id
}

