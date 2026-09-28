terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatedaswwy"
    container_name       = "tfstate"
    key                  = "flask-app.tfstate"
  }
}

provider "azurerm" {
  features {}
}

locals {
  common_tags = {
    project    = "flask-app"
    managed_by = "terraform"
  }
}


resource "azurerm_resource_group" "tf_lab" {
  name     = "rg-terraform-lab"
  location = "denmarkeast"
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "tf_lab" {
  name                = "vnet-terraform-lab"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.tf_lab.location
  resource_group_name = azurerm_resource_group.tf_lab.name
}

resource "azurerm_subnet" "tf_lab" {
  name                 = "snet-terraform-lab"
  resource_group_name  = azurerm_resource_group.tf_lab.name
  virtual_network_name = azurerm_virtual_network.tf_lab.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "tf_lab" {
  name                = "nsg-terraform-lab"
  location            = azurerm_resource_group.tf_lab.location
  resource_group_name = azurerm_resource_group.tf_lab.name

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${var.allowed_ip}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Flask"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "${var.allowed_ip}/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "tf_lab" {
  subnet_id                 = azurerm_subnet.tf_lab.id
  network_security_group_id = azurerm_network_security_group.tf_lab.id
}

resource "azurerm_public_ip" "tf_lab" {
  name                = "pip-terraform-lab"
  location            = azurerm_resource_group.tf_lab.location
  resource_group_name = azurerm_resource_group.tf_lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "tf_lab" {
  name                = "nic-terraform-lab"
  location            = azurerm_resource_group.tf_lab.location
  resource_group_name = azurerm_resource_group.tf_lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf_lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf_lab.id
  }
}

resource "azurerm_linux_virtual_machine" "tf_lab" {
  name                  = "vm-terraform-lab"
  location              = azurerm_resource_group.tf_lab.location
  resource_group_name   = azurerm_resource_group.tf_lab.name
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.tf_lab.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  tags = local.common_tags

}

