terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.95.0"
    }
  }
  required_version = "1.7.4"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_sl_prod" {
  name     = "rg-sl-prod"
  location = "West US"
}

locals {
  vincent_mahnke = {
    full_name          = "Vincent Mahnke"
    initials           = join("", [for x in split(" ", "Vincent Mahnke") : lower(substr(x, 0, 1))])
    tenant_id          = "41eb501a-f671-4ce0-a5bf-b64168c3705f"
    object_id          = "7dac8181-b972-4612-8738-094828b1a3ff"
    phone_country_code = "49"
    phone_number       = "1721358162"
    email_address      = "v.mahnke+azalert@gmail.com"
  }
  top_level_domain = "studio-lovelies.com"
}

module "application_insights" {
  source         = "./application_insights"
  resource_group = azurerm_resource_group.rg_sl_prod
}

module "website" {
  source                                 = "./website"
  top_level_domain                       = local.top_level_domain
  resource_group                         = azurerm_resource_group.rg_sl_prod
  alerted_user                           = local.vincent_mahnke
  application_insights_connection_string = module.application_insights.connection_string
  secrets = {
    discord_webhook_url = var.discord_webhook_url
    smtp_host           = var.smtp_host
    smtp_port           = var.smtp_port
    smtp_username       = var.smtp_username
    smtp_password       = var.smtp_password
    smtp_from           = var.smtp_from
  }
}

module "networking" {
  source         = "./networking"
  resource_group = azurerm_resource_group.rg_sl_prod
  web_app        = module.website.web_app
}