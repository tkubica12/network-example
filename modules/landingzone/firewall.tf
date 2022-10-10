resource "azurerm_firewall_policy" "main" {
  name                = "${var.name_prefix}-fw-policy"
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_public_ip" "fw" {
  name                = "${var.name_prefix}-fw-ip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "main" {
  name                = "${var.name_prefix}-fw"
  location            = var.location
  resource_group_name = var.rg_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.main.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fw.id
    public_ip_address_id = azurerm_public_ip.fw.id
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "main" {
  name               = "allow-all"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 500

  network_rule_collection {
    name     = "allow-all"
    priority = 400
    action   = "Allow"
    rule {
      name                  = "all"
      protocols             = ["TCP", "UDP", "ICMP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}
