provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-hub-${var.location}-001"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Data Plane Subnet for Azure Firewall
resource "azurerm_subnet" "fw_data_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.fw_data_subnet_prefix
}

# Management Plane Subnet for Azure Firewall
resource "azurerm_subnet" "fw_mgmt_subnet" {
  name                 = "AzureFirewallMgmtSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.fw_mgmt_subnet_prefix
}

# Public IP for the Data Plane (if required for internet-facing SNAT/DNAT)
resource "azurerm_public_ip" "fw_data_pip" {
  name                = "pip-afw-data-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Public IP for the Management Plane (CRITICAL for Forced Tunneling)
resource "azurerm_public_ip" "fw_mgmt_pip" {
  name                = "pip-afw-mgmt-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Firewall Deployment (Forced Tunneling Configuration)
resource "azurerm_firewall" "fw" {
  name                = "fw-hub-${var.location}-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  # The Data Plane Configuration
  ip_configuration {
    name                 = "data-ip-config"
    subnet_id            = azurerm_subnet.fw_data_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_data_pip.id
  }

  # THE FIX: The Management Plane (Microsoft's escape hatch)
  # By including this block, the Firewall is automatically deployed in Forced Tunneling mode.
  management_ip_configuration {
    name                 = "mgmt-ip-config"
    subnet_id            = azurerm_subnet.fw_mgmt_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_mgmt_pip.id
  }
}

# -----------------------------------------------------
# Route Table Configuration
# -----------------------------------------------------

# Route Table for the Data Plane (Forcing traffic to on-prem via NVA)
resource "azurerm_route_table" "rt_fw_data" {
  name                          = "rt-afw-data-001"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  bgp_route_propagation_enabled = true

  route {
    name                   = "Force-Tunnel-OnPrem"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.on_prem_firewall_ip # The IP of your on-premise inspection device
  }
}

resource "azurerm_subnet_route_table_association" "assoc_fw_data" {
  subnet_id      = azurerm_subnet.fw_data_subnet.id
  route_table_id = azurerm_route_table.rt_fw_data.id
}

# Route Table for the Management Plane (Escaping to the Internet)
# Only strictly necessary if there is an overriding policy, but excellent for explicit architecture.
resource "azurerm_route_table" "rt_fw_mgmt" {
  name                          = "rt-afw-mgmt-001"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  bgp_route_propagation_enabled = true

  route {
    name           = "Direct-Internet-Mgmt"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "assoc_fw_mgmt" {
  subnet_id      = azurerm_subnet.fw_mgmt_subnet.id
  route_table_id = azurerm_route_table.rt_fw_mgmt.id
}
