output "firewall_private_ip" {
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  description = "The internal IP to route traffic towards."
}

output "route_table_data_id" {
  value       = azurerm_route_table.rt_fw_data.id
  description = "The ID of the data plane route table."
}

output "route_table_mgmt_id" {
  value       = azurerm_route_table.rt_fw_mgmt.id
  description = "The ID of the management plane route table."
}
