// Resource group
resource "azurerm_resource_group" "onprem" {
  name     = "onprem"
  location = "westeurope"
}

// Virtual network
resource "azurerm_virtual_network" "onprem" {
  name                = "onprem"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  address_space       = ["10.99.0.0/16"]
}

resource "azurerm_subnet" "onprem_vm" {
  name                 = "vm"
  virtual_network_name = azurerm_virtual_network.onprem.name
  resource_group_name  = azurerm_resource_group.onprem.name
  address_prefixes     = ["10.99.1.0/24"]
}

resource "azurerm_subnet" "onprem_gw" {
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.onprem.name
  resource_group_name  = azurerm_resource_group.onprem.name
  address_prefixes     = ["10.99.0.0/24"]
}

// VPN GW
resource "azurerm_public_ip" "onprem_vpn" {
  name                = "onprem-vpn-ip"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_virtual_network_gateway" "onprem_vpn" {
  name                = "onprem-vpn"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1AZ"
  generation          = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.onprem_vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem_gw.id
  }
}

// VPN - peers
resource "azurerm_local_network_gateway" "onprem_peer_reg1" {
  name                = "onprem-peer-reg1"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  gateway_address     = module.reg1.vpn_ip
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_local_network_gateway" "onprem_peer_reg2" {
  name                = "onprem-peer-reg2"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  gateway_address     = module.reg2.vpn_ip
  address_space       = ["10.2.0.0/16"]
}

// VPN connections
resource "azurerm_virtual_network_gateway_connection" "onprem_to_reg1" {
  name                       = "onprem_to_reg1"
  resource_group_name        = azurerm_resource_group.onprem.name
  location                   = azurerm_resource_group.onprem.location
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem_vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem_peer_reg1.id
  enable_bgp                 = false
  shared_key                 = "Azure12345678"
}

resource "azurerm_virtual_network_gateway_connection" "onprem_to_reg2" {
  name                       = "onprem_to_reg2"
  resource_group_name        = azurerm_resource_group.onprem.name
  location                   = azurerm_resource_group.onprem.location
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem_vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem_peer_reg2.id
  enable_bgp                 = false
  shared_key                 = "Azure12345678"
}


// Virtual Machine
resource "azurerm_network_interface" "onprem" {
  name                = "onprem-vm-nic"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.onprem_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "onprem" {
  name                            = "onprem-vm"
  resource_group_name             = azurerm_resource_group.onprem.name
  location                        = azurerm_resource_group.onprem.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "Azure12345678"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.onprem.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  boot_diagnostics {}
}
