resource "azurerm_resource_group" "rg" {
  for_each = var.environments
  location = var.location
  name     = "rg-${each.key}"
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.environments
  name                = "vnet-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  address_space = [
    "10.${each.key == "dev" ? 1 : each.key == "qa" ? 2 : 3}.0.0/16"
  ]

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.environments
  name                 = "subnet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes = [
    "10.${each.key == "dev" ? 1 : each.key == "qa" ? 2 : 3}.1.0/24"
  ]
  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_public_ip" "pip" {
  for_each            = var.environments
  name                = "pp-${each.key}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  for_each            = var.environments
  name                = "nic-${each.key}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = var.location
  ip_configuration {
    name                          = "ipconfig-${each.key}"
    subnet_id                     = azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = var.environments
  name                = "vm-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  size                = each.value
  admin_username      = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_publickey_path)
  }
  disable_password_authentication = true
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  os_disk {
    name                 = "osdisk-${each.key}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]
}