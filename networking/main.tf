resource "azurerm_virtual_network" "vnet_sl_prod" {
  name                = "vnet-sl-prod"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default" {
  name                                          = "default"
  resource_group_name                           = var.resource_group.name
  virtual_network_name                          = azurerm_virtual_network.vnet_sl_prod.name
  address_prefixes                              = ["10.0.0.0/24"]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = true
}

resource "azurerm_network_interface" "pe_asp_sl_prod_nic" {
  name                = "pe-asp-sl-prod.nic.a82dcd5a-8c1c-4bbd-b26f-c247c5465560"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  ip_configuration {
    name                          = "privateEndpointIpConfig.8ed6cd6c-1552-44e3-a8cc-adfd3138ecb7"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_private_endpoint" "pe_asp_sl_prod" {
  name                = "pe-asp-sl-prod"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  subnet_id           = azurerm_subnet.default.id
  private_service_connection {
    name                           = "pe-asp-sl-prod-a995"
    private_connection_resource_id = var.web_app.id
    subresource_names              = ["sites-preview"]
    is_manual_connection           = false
  }
  tags = {}
}