resource "azurerm_resource_group" "reg1" {
  name     = "reg1"
  location = "northeurope"
}

resource "azurerm_resource_group" "reg2" {
  name     = "reg2"
  location = "westeurope"
}

module "reg1" {
  source                    = "./modules/landingzone"
  location                  = azurerm_resource_group.reg1.location
  rg_name                   = azurerm_resource_group.reg1.name
  name_prefix               = "reg1"
  range                     = "10.1.0.0/16"
  p2s_vpn_range             = "10.1.254.0/24"
  onprem_ranges             = ["10.99.0.0/16"]
  onprem_vpn_ip             = azurerm_public_ip.onprem_vpn.ip_address
  enable_vpn                = true
  route_onprem_via_firewall = false
  spoke_count               = 2
}

module "reg2" {
  source                    = "./modules/landingzone"
  location                  = azurerm_resource_group.reg2.location
  rg_name                   = azurerm_resource_group.reg2.name
  name_prefix               = "reg2"
  range                     = "10.2.0.0/16"
  p2s_vpn_range             = "10.2.254.0/24"
  onprem_ranges             = ["10.99.0.0/16"]
  onprem_vpn_ip             = azurerm_public_ip.onprem_vpn.ip_address
  enable_vpn                = true
  route_onprem_via_firewall = false
  spoke_count               = 2
}
