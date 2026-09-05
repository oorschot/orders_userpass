output "path" {
  description = "The configured auth mount path, without the auth/ prefix."
  value       = vault_auth_backend.this.path
}

output "accessor" {
  description = "Vault accessor assigned to this auth mount."
  value       = vault_auth_backend.this.accessor
}

output "login_path" {
  description = "Userpass login endpoint template."
  value       = "auth/${vault_auth_backend.this.path}/login/<username>"
}

output "configured_usernames" {
  description = "The usernames managed by this module."
  value       = sort(keys(var.users))
}
