output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}
  
output "hub_vnet_name" {
  value = azurerm_virtual_network.hub.name
}
  
output "fw_subnet_id" {
  value = azurerm_subnet.fw.id
}

output "fw_ip" {
  value = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "vpn_ip" {
  value = var.enable_vpn ? azurerm_public_ip.vpn[0].ip_address : ""
}

output "bgp_peer_ip" {
  value = var.enable_vpn ? azurerm_virtual_network_gateway.main[0].bgp_settings[0].peering_addresses[0].default_addresses[0] : ""
}

output "spokes_ranges" {
  value = azurerm_virtual_network.spoke.*.address_space
}