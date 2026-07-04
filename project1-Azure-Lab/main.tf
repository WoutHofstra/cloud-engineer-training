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
  resource_group_name = azurerm_resource_group.main.name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "workload" {
  name = "subnet-azurelab-vm"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name = "subnet-azurelab-bastion"
  resource_group_name = azurerm_resource_group.main.name
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

  resource_group_name = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.workload.name
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

resource "azurerm_virtual_machine" "main" {
  name = "vm-azurelab-001"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size = "Standard_B1s"

  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }

  storage_os_disk {
    name = "disk-azurelab-001"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "vm-name"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_public_ip" "main" {
  name = "test-ip"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method = "static"
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