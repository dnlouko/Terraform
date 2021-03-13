# Required Providers Block
terraform {
  required_providers {
    # whilst the "version" attribute is optional, we recommend pinning to a given version of the Provider
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.20.0"
    }
  }
}
# Configure the Azure Provider
provider "azurerm" {
  # Aways need to put the features for it to work{}
  features {}
}

locals {
  env_and_project = upper("${var.environment}-${var.name}")
  project_name    = upper("-${var.name}-")
}

# Resource Group Definition
resource "azurerm_resource_group" "this_rg" {
  name     = "RG-${local.env_and_project}"
  location = var.location
  tags     = var.tags
}

# VNet Setup
resource "azurerm_virtual_network" "this_vnet" {
  name                = "VNET-${local.env_and_project}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
  tags                = var.tags
  # The depends on is used to setup order of deploy for the specified resources
  # depends_on = [azurerm_resource_group.main]
}

# Subnet Setup
resource "azurerm_subnet" "this_snet" {
  name                 = "SUBNET-${local.env_and_project}"
  resource_group_name  = azurerm_resource_group.this_rg.name
  virtual_network_name = azurerm_virtual_network.this_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP Setup
resource "azurerm_public_ip" "this_public_ip" {
  count               = var.numberOfRes
  name                = "LVM${local.project_name}${count.index+1}-PUBIP"
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
  allocation_method   = "Dynamic"
  tags                = var.tags
  # domain_name_label             = "sometestdn"
}

# NIC Setup
resource "azurerm_network_interface" "this_nic" {
  count               = var.numberOfRes
  name                = upper("LVM${local.project_name}${count.index+1}-NIC")
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
  tags                = var.tags
  ip_configuration {
    name                          = "LVM${local.project_name}${count.index+1}-NIC-IPCONFIG"
    subnet_id                     = azurerm_subnet.this_snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = element(var.ip, count.index)
    public_ip_address_id          = element(azurerm_public_ip.this_public_ip.*.id, count.index)
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "sg_association" {
  # Had to add the count because we have counters on VM ane NICs so it can take the correct values
  # Because of the count we had to set the ID as Element in the nic.ID for it to work
  # Security group configured into the security.tf file into the same directory
  count                     = var.numberOfRes
  network_interface_id      = element(azurerm_network_interface.this_nic.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.security.id
}

# Private Key Setup for Linux Machines
resource "tls_private_key" "this_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Linux VM Setup
resource "azurerm_linux_virtual_machine" "this_vm" {
  #Core Infrastructure settings
  count                           = var.numberOfRes
  name                            = "LVM${local.project_name}${count.index+1}"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.this_rg.name
  network_interface_ids           = [element(azurerm_network_interface.this_nic.*.id, count.index)]  # Inside squarebrackets in order to get only one nic inside of the list
  size                            = "Standard_B1s"
  tags                            = var.tags
  computer_name                   = "LVM${local.project_name}${count.index+1}"
  admin_username                  = var.userName
  disable_password_authentication = true
  
  #VirtualMachine OS Settings
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  # Main Storage Disk
  os_disk {
    name                 = "LVM${local.project_name}${count.index+1}-OSD"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  # Linux VM SSH Key
  admin_ssh_key {
    username   = var.userName
    public_key = tls_private_key.this_ssh_key.public_key_openssh
  }
}
# Command to run after VM Creation
resource "azurerm_virtual_machine_extension" "command" {
  count                = length(azurerm_network_interface.this_nic)
  name                 = "get_docker"
  virtual_machine_id   = element(azurerm_linux_virtual_machine.this_vm.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "${var.script}"
    }
    SETTINGS
}