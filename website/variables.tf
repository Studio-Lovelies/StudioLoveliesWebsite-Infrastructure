variable "resource_group" {
  type = object({
    name = string
    location = string
  })
}

variable "top_level_domain" {
  type = string
}

variable "application_insights_connection_string" {
  description = "The connection string for the Application Insights resource"
  type        = string
}

variable "alerted_user" {
  type = object({
    full_name = string
    initials = string
    tenant_id = string
    object_id = string
    phone_country_code = string
    phone_number = string
    email_address = string
  })
}

variable "secrets" {
  type = object({
    discord_webhook_url = string
    smtp_host = string
    smtp_port = string
    smtp_username = string
    smtp_password = string
    smtp_from = string
  })
}