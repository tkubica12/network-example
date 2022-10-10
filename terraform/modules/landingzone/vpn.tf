// VPN 
resource "azurerm_public_ip" "vpn" {
  count               = var.enable_vpn ? 1 : 0
  name                = "${var.name_prefix}-vpn-ip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_virtual_network_gateway" "main" {
  count               = var.enable_vpn ? 1 : 0
  name                = "${var.name_prefix}-vpn"
  resource_group_name = var.rg_name
  location            = var.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1AZ"
  generation          = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw.id
  }

  vpn_client_configuration {
    address_space = [var.p2s_vpn_range]
    root_certificate {
      name = "P2SRootCert"
      public_cert_data = <<EOF
MIIC5zCCAc+gAwIBAgIQbR+RSGSTV5hEv4rbmlMWXTANBgkqhkiG9w0BAQsFADAW
MRQwEgYDVQQDDAtQMlNSb290Q2VydDAeFw0yMjEwMTAxMTM3MjhaFw0yMzEwMTAx
MTU3MjhaMBYxFDASBgNVBAMMC1AyU1Jvb3RDZXJ0MIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA09khU9NFHSFJI2F3lvBflz0C0JD+hz+wRa7v0Avp4p5D
ztVgIf6fgAa3fkj9tekQQygMkOQOnvBV1SCoFyfBjvKqQ5e8dXOjMiU49cZRsEtB
RpjJT/YrmB89fvDbUUhJAiz5Eij8WplVqLEmHvDZL2EGLhAlwi5q0AdC1hHsORYJ
oL2L5qcDY2FMMs5XaQew7rDru0ncmgGRIbtb4v0MVwpZrF0mDrGQy1NjuFaE1+nh
sj9B88PBAEVxdMcX3ZH66TWXPuWBVZf1/mtQX2L5py5ZFa+AVW1DJqdVekW5zDW7
Pl/gjrPT9m7e6xTmPmz8kbKTZBttWofy05BE+8amRQIDAQABozEwLzAOBgNVHQ8B
Af8EBAMCAgQwHQYDVR0OBBYEFLVeDxP9tdVEATq/5+tLnR3lWQxbMA0GCSqGSIb3
DQEBCwUAA4IBAQCgptZIVE91YtAamEdhcf0W459oBY0WWobaFIuuFPErAdIaw7gi
r5N7e4z/rLGsf/8lEy6mZfK5TPDPF9AmxMNjuuL/Y/+5DtuEfzNCn1AIK1iOkTBQ
col1G/90S1GXhTIhT4GRXsjnDqyAc5NUI1cbiunDnWeMYH0e7hQZmiMUrsvRK2Zn
GJEbZEpz6PmcFDRVzbzplsUK5Ah42Bleg0nL/QF8UwjYh3RroLBI2sBlyBj8I6tl
AUaNJ80p31wAj9ak2y0BKPiKKuZV/hd3o36fsTsYh6hTSaAJqgacmHo1Doc2A0UN
XQ+fNWfnxW0FSUPOqVaV6+8Xi86r3w+OemQp
EOF
    }
  }
}

// VPN peer (onprem)
resource "azurerm_local_network_gateway" "main" {
  count               = var.enable_vpn ? 1 : 0
  name                = "${var.name_prefix}-onprem"
  resource_group_name = var.rg_name
  location            = var.location
  gateway_address     = var.onprem_vpn_ip
  address_space       = var.onprem_ranges
}

// VPN connection
resource "azurerm_virtual_network_gateway_connection" "reg_to_onprem" {
  count                      = var.enable_vpn ? 1 : 0
  name                       = "reg_to_onprem"
  resource_group_name        = var.rg_name
  location                   = var.location
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main[0].id
  local_network_gateway_id   = azurerm_local_network_gateway.main[0].id
  enable_bgp                 = false
  shared_key                 = "Azure12345678"
}

// Send traffic from VPN to FW
resource "azurerm_route_table" "vpn" {
  count                         = (var.enable_vpn && var.route_onprem_via_firewall) ? 1 : 0
  name                          = "${var.name_prefix}-vpn-rt"
  resource_group_name           = var.rg_name
  location                      = var.location
  disable_bgp_route_propagation = false

  route {
    name                   = "internallToFirewall"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "vpn" {
  count          = (var.enable_vpn && var.route_onprem_via_firewall) ? 1 : 0
  subnet_id      = azurerm_subnet.gw.id
  route_table_id = azurerm_route_table.vpn[0].id
}
