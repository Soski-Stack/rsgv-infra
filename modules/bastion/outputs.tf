output "bastion_instance_name" {
  description = "Name of the bastion GCE instance"
  value       = google_compute_instance.bastion.name
}

output "bastion_ip_private" {
  description = "Private IP address of the bastion VM"
  value       = google_compute_instance.bastion.network_interface[0].network_ip
}

output "bastion_ssh_user" {
  description = "SSH username format for OS Login (use with gcloud compute ssh)"
  value       = "sa_${replace(var.service_account_email, "@", "_")}"
}

output "bastion_zone" {
  description = "Zone of the bastion VM"
  value       = google_compute_instance.bastion.zone
}

output "iap_ssh_command" {
  description = "Example gcloud IAP SSH command to connect to bastion"
  value       = "gcloud compute ssh ${google_compute_instance.bastion.name} --project=${var.project_id} --zone=${var.zone} --tunnel-through-iap"
}
