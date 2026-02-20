variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-hub-network-prod-001"
}

variable "location" {
  description = "The Azure region to deploy into"
  type        = string
  default     = "uksouth"
}

variable "vnet_address_space" {
  description = "The address space for the Hub Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "fw_data_subnet_prefix" {
  description = "The subnet prefix for the AzureFirewallSubnet"
  type        = list(string)
  default     = ["10.0.1.0/26"]
}

variable "fw_mgmt_subnet_prefix" {
  description = "The subnet prefix for the AzureFirewallMgmtSubnet"
  type        = list(string)
  default     = ["10.0.2.0/26"]
}

variable "on_prem_firewall_ip" {
  description = "The IP address of the on-premises firewall or NVA for forced tunneling"
  type        = string
  default     = "192.168.100.10"
}
