terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.96.0"
    }
  }
}

variable "prefix" {}
variable "resource_group_name" {}
variable "resource_group_location" {}
variable "resource_group_subnet_id" {}
variable "network_security_group_name" {}

provider "azurerm" {
  features {}
}

resource "azurerm_linux_virtual_machine" "azvm" {
  name                = "${var.prefix}-vm"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = "Standard_F2"
  admin_username      = "admin"
  network_interface_ids = [
    azurerm_network_interface.azvm.id,
  ]

  admin_ssh_key {
    username   = "admin"
    public_key = file("./.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "60"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "azvm" {
  name                = "${var.prefix}-nic"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.resource_group_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azvm.id
  }
}

resource "azurerm_public_ip" "azvm" {
  name                = "${var.prefix}-pip"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Static"
}

resource "azurerm_network_security_rule" "ssh_port" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "azurerm_network_security_rule" "vault_port" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8200"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "null_resource" "deploy-vault-instance" {
  provisioner "file" {
    source      = "deploy-vault-instance.tpl"
    destination = "/tmp/deploy-vault-instance.bash"

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file("./.ssh/id_rsa")
      host        = azurerm_public_ip.azvm.ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [

    ]
    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file("./.ssh/id_rsa")
      host        = azurerm_public_ip.azvm.ip_address
    }
  }
}

