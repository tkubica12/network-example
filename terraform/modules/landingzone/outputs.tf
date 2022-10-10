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
