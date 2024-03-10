# DISCORD_WEBHOOK_URL
# SMTP_HOST
# SMTP_PORT
# SMTP_USERNAME
# SMTP_PASSWORD
# SMTP_FROM

variable "discord_webhook_url" {
  description = "Discord Webhook URL to call when the contact form is submitted"
  type        = string
}

variable "smtp_host" {
  description = "SMTP host used for contact form entries"
  type        = string
}

variable "smtp_port" {
  description = "SMTP port used for contact form entries"
  type        = string
}

variable "smtp_username" {
  description = "SMTP username used for contact form entries"
  type        = string
}

variable "smtp_password" {
  description = "SMTP password used for contact form entries"
  type        = string
}

variable "smtp_from" {
  description = "SMTP from-address used for contact form entries"
  type        = string
}