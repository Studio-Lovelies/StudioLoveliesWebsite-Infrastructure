variable "resource_group" {
  type = object({
    name = string
    location = string
  })
}

variable "web_app" {
  type = object({
    id = string
  })
}