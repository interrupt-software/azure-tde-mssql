terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.96.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_password" "password" {
  length  = 32
  special = false
}

# Create a resource group for easy cleanup
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-mssql-tde-dev"
  location = var.location
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = "mssql-tde-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2s"
  admin_username      = "mssql-tde-dev"
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2019-ws2019"
    sku       = "sqldev-gen2"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "mssql-tde-dev-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Create a network
resource "azurerm_virtual_network" "main" {
  name                = "mssql-tde-dev-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_public_ip" "main" {
  name                = "mssql-tde-dev-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Allow some traffic into the VM
resource "azurerm_network_security_group" "main" {
  name                = "mssql-tde-dev-nsg"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "Allow RDP"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name

  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "3389"
  source_address_prefix      = var.allowed_ip_address
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "ping" {
  name                        = "Allow ICMP pings"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name

  priority                   = 102
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Icmp"
  source_address_prefix      = var.allowed_ip_address
  destination_address_prefix = "*"

  # These don't make sense for ICMP but are still required
  source_port_range      = "*"
  destination_port_range = "*"
}
