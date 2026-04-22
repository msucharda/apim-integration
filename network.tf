# ------------------------------------------------------------------------------
# Network Security Groups (created before VNet so inline subnets can reference them)
# ------------------------------------------------------------------------------

resource "azurerm_network_security_group" "pe" {
  name                = "nsg-snet-pe-${local.name_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_network_security_group" "apim" {
  name                = "nsg-snet-apim-${local.name_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowAPIMManagement"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6390"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Virtual Network with inline subnets (NSG attached at creation to satisfy policy)
# ------------------------------------------------------------------------------

resource "azurerm_virtual_network" "main" {
  name                = local.resource_names.vnet
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
  tags                = local.common_tags

  subnet {
    name             = "snet-pe"
    address_prefixes = [var.subnet_prefixes["pe"]]
    security_group   = azurerm_network_security_group.pe.id
  }

  subnet {
    name             = "snet-apim"
    address_prefixes = [var.subnet_prefixes["apim"]]
    security_group   = azurerm_network_security_group.apim.id

    delegation {
      name = "apim-delegation"
      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}
