output "github_action_private_key" {
  description = "Private key used by the github action to deploy k8s"
  value = google_service_account_key.github_action_key.private_key
  sensitive = true
}
