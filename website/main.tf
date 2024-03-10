resource "azurerm_service_plan" "asp_sl_prod" {
  name                = "asp-sl-prod"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "studio_lovelies" {
  name                = "studio-lovelies"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  service_plan_id     = azurerm_service_plan.asp_sl_prod.id
  site_config {
    always_on = false
    health_check_path = "/"
  }
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.application_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "DISCORD_AVATAR_URL"                         = "https://${var.top_level_domain}/assets/images/SL-discord-logo.png"
    "DISCORD_USERNAME"                           = "${var.top_level_domain} Contact Form"
    "DISCORD_WEBHOOK_URL"                        = var.secrets.discord_webhook_url
    "SMTP_HOST"                                  = var.secrets.smtp_host
    "SMTP_PORT"                                  = var.secrets.smtp_port
    "SMTP_USERNAME"                              = var.secrets.smtp_username
    "SMTP_PASSWORD"                              = var.secrets.smtp_password
    "SMTP_FROM"                                  = var.secrets.smtp_from
    "SMTP_TO"                                    = "contactform@${var.top_level_domain}"
    "XDT_MicrosoftApplicationInsights_Mode"      = "default"
  }
  https_only = true
  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 90
        retention_in_mb   = 35
      }
    }
  }
}

resource "azurerm_linux_web_app_slot" "preview" {
  name           = "preview"
  app_service_id = azurerm_linux_web_app.studio_lovelies.id
  site_config {
    always_on = false
    health_check_path = "/"
  }
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.application_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "DISCORD_AVATAR_URL"                         = "https://preview.${var.top_level_domain}/assets/images/SL-discord-logo.png"
    "DISCORD_USERNAME"                           = "preview.${var.top_level_domain} Contact Form"
    "DISCORD_WEBHOOK_URL"                        = var.secrets.discord_webhook_url
    "SMTP_HOST"                                  = var.secrets.smtp_host
    "SMTP_PORT"                                  = var.secrets.smtp_port
    "SMTP_USERNAME"                              = var.secrets.smtp_username
    "SMTP_PASSWORD"                              = var.secrets.smtp_password
    "SMTP_FROM"                                  = var.secrets.smtp_from
    "SMTP_TO"                                    = "contactform-preview@${var.top_level_domain}"
    "XDT_MicrosoftApplicationInsights_Mode"      = "default"
  }
  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 90
        retention_in_mb   = 35
      }
    }
  }
  https_only = true
}

resource "azurerm_app_service_slot_custom_hostname_binding" "dev" {
  hostname            = "dev.${var.top_level_domain}"
  app_service_slot_id = azurerm_linux_web_app_slot.preview.id
  ssl_state           = "SniEnabled"
}

resource "azurerm_app_service_slot_custom_hostname_binding" "preview" {
  hostname            = "preview.${var.top_level_domain}"
  app_service_slot_id = azurerm_linux_web_app_slot.preview.id
  ssl_state           = "SniEnabled"
}

resource "azurerm_app_service_custom_hostname_binding" "www" {
  hostname            = "${var.top_level_domain}"
  app_service_name    = azurerm_linux_web_app.studio_lovelies.name
  resource_group_name = var.resource_group.name
  ssl_state           = "SniEnabled"
}

resource "azurerm_app_service_managed_certificate" "dev_cert" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.www.id
  lifecycle {
    ignore_changes = [custom_hostname_binding_id]
  }
}

resource "azurerm_app_service_managed_certificate" "preview_cert" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.www.id
  lifecycle {
    ignore_changes = [custom_hostname_binding_id]
  }
}

resource "azurerm_app_service_managed_certificate" "www_cert" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.www.id
  lifecycle {
    ignore_changes = [custom_hostname_binding_id]
  }
}

resource "azurerm_monitor_action_group" "ag_sl_global" {
  name                = "ag-sl-global"
  resource_group_name = var.resource_group.name
  short_name          = "${var.alerted_user.initials}-global"
  email_receiver {
    email_address           = var.alerted_user.email_address
    name                    = "${var.alerted_user.full_name}_-EmailAction-"
    use_common_alert_schema = true
  }

  sms_receiver {
    country_code = var.alerted_user.phone_country_code
    name         = "${var.alerted_user.full_name}_-SMSAction-"
    phone_number = var.alerted_user.phone_number
  }
}

resource "azurerm_monitor_metric_alert" "metric_alert" {
  name                 = "studiolovelies.com PROD is unavailable"
  resource_group_name  = var.resource_group.name
  scopes               = [azurerm_linux_web_app.studio_lovelies.id]
  severity             = 0
  enabled              = true
  auto_mitigate        = true
  frequency            = "PT1M"
  window_size          = "PT5M"
  target_resource_type = "Microsoft.Web/sites"
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HealthCheckStatus"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = 100
  }
  action {
    action_group_id = azurerm_monitor_action_group.ag_sl_global.id
  }
}