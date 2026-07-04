terraform {
  required_version = ">= 1.15.7"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name = "rg-azurelab-001"
  location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
  name = "vnet-azurelab-001"
  location = "West Europe"
  resource_group_name = azurerm_resource_group.main
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "workload" {
  name = "subnet-azurelab-vm"
  resource_group_name = azurerm_resource_group.main
  virtual_network_name = azurerm_virtual_network.main
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name = "subnet-azurelab-bastion"
  resource_group_name = azurerm_resource_group.main
  virtual_network_name = azurerm_virtual_network.main
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "workload" {
  name = "nsg-workload"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name = "Allow-SSH-From-Home"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"

  source_port_range = "*"
  destination_port_range = "22"

  source_address_prefix = "62.38.138.102/32"
  destination_address_prefix = "*"

  resource_group_name = azurerm_resource_group.main
  network_security_group_name = azurerm_network_security_group.workload.name
}

