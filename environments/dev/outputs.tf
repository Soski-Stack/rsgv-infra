
output "bastion_ip_private" {
  description = "Private IP of the bastion VM"
  value       = module.bastion.bastion_ip_private
}

output "bastion_ssh_command" {
  description = "IAP SSH command to connect to bastion"
  value       = module.bastion.iap_ssh_command
}
