provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "sasirg1" {
  name     = "sasirg1"
  location = "east us"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "sasi-vnet1"
  address_space       = ["14.0.0.0/16"]
  location            = azurerm_resource_group.sasirg1.location
  resource_group_name = azurerm_resource_group.sasirg1.name
}

resource "azurerm_subnet" "snet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.sasirg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["14.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "sasi-nic"
  location            = azurerm_resource_group.sasirg1.location
  resource_group_name = azurerm_resource_group.sasirg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "sasivm1"
  resource_group_name = azurerm_resource_group.sasirg1.name
  location            = azurerm_resource_group.sasirg1.location
  size                = "Standard_F2"
  admin_username      = "priyanka"
  admin_password      = "sasi@2022"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}