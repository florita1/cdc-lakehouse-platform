output "argocd_server_url" {
  value       = "https://localhost:8080" # For port-forwarded access
  description = "Argo CD UI URL"
}

output "argocd_admin_password_cmd" {
  value       = "kubectl -n wal-cdc-argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d && echo"
  description = "Command to retrieve Argo CD admin password"
}