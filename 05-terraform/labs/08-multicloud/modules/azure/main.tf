resource "azurerm_resource_group" "rg" {
    name     = var.azure_resource_group_name
    location = var.azure_location
}

resource "azurerm_virtual_network" "vnet" {
    name                = "${var.azure_resource_group_name}-vnet"
    address_space       = ["10.0.0.0/16"]
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "subnet" {
    name                 = "${var.azure_resource_group_name}-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
    count               = var.azure_vm_count
    name                = "${var.azure_resource_group_name}-public-ip-${count.index+1}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
    count               = var.azure_vm_count
    name                = "${var.azure_resource_group_name}-nic-${count.index+1}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    count               = var.azure_vm_count
    name                = "${var.azure_resource_group_name}-vm-${count.index+1}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.azure_vm_size
    admin_username      = var.azure_admin_username
    admin_password      = var.azure_admin_password
    disable_password_authentication = false
    network_interface_ids = [azurerm_network_interface.nic[count.index].id]

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
}

resource "azurerm_storage_account" "storage_account" {
    count                    = var.azure_storage_account_count
    name                     = "${var.azure_storage_account_prefix}${count.index+1}"
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = azurerm_resource_group.rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}