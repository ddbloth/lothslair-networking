output "public_ip_address" {
  value = azurerm_linux_virtual_machine.tf_vm.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.tf_vm_ssh.private_key_pem
  sensitive = true
}

output "name" {
  value     = azurerm_linux_virtual_machine.tf_vm.name
  sensitive = false
}

output "id" {
  value     = azurerm_linux_virtual_machine.tf_vm.id
  sensitive = false
}
