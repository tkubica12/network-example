resource "azurerm_network_interface" "sub01" {
  count               = var.spoke_count
  name                = "${var.name_prefix}-spoke-${count.index + 1}-sub01"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub01[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "sub02" {
  count               = var.spoke_count
  name                = "${var.name_prefix}-spoke-${count.index + 1}-sub02"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub02[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "sub01" {
  count                           = var.spoke_count
  name                            = "${var.name_prefix}-spoke-${count.index + 1}-sub01"
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "Azure12345678"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.sub01[count.index].id
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

resource "azurerm_linux_virtual_machine" "sub02" {
  count               = var.spoke_count
  name                = "${var.name_prefix}-spoke-${count.index + 1}-sub02"
  resource_group_name = var.rg_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Azure12345678"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.sub02[count.index].id
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
