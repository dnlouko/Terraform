output "rg_name" {
  value = azurerm_resource_group.this_rg.name
}
output "vnet_data" {
  value = azurerm_virtual_network.this_vnet
}
output "subenet_data" {
  value = azurerm_subnet.this_snet
}
output "vm_data" {
  # If we have multiple resources, we need to ad the * to get every info
  value = azurerm_linux_virtual_machine.this_vm.*
}

resource "local_file" "this_private_key" {
  content  = tls_private_key.this_ssh_key.private_key_pem
  filename = "${var.name}.pem"
}