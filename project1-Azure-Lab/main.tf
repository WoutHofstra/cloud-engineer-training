
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.0"
    }
  }

  backend "azurerm" {
        resource_group_name = "rg-terraform-state"
        storage_account_name = "storageterraformstate967"
        container_name = "state"
        key = "coolkey1234"
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
  resource_group_name = azurerm_resource_group.main.name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "workload" {
  name = "subnet-azurelab-vm"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.2.0/26"]
}

resource "azurerm_network_security_group" "workload" {
  name = "nsg-workload"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name = "Allow-SSH-From-Bastion"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"

  source_port_range = "*"
  destination_port_range = "22"

  source_address_prefix = "10.0.2.0/24"
  destination_address_prefix = "*"

  resource_group_name = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.workload.name
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

resource "azurerm_network_interface" "main" {
  name = "nic-azurelab-001"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name = "ip-config-test-001"
    subnet_id = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name = "vm-azurelab-001"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  size = "Standard_D2als_v6"

  admin_username = "testadmin"

  admin_password = "Password1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_public_ip" "main" {
  name = "pip-bastion-001"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "main" {
  name = "bastion-azurelab-001"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name = "config"
    subnet_id = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.main.id
  }
}
