variable "vault_address" {
  description = "Vault API address for this environment."
  type        = string
}

variable "vault_ca_cert_file" {
  description = "Path to the CA certificate or self-signed Vault certificate."
  type        = string
}

variable "alice_password" {
  description = "Initial password for the Vault Userpass user alice."
  type        = string
  sensitive   = true
}

variable "bob_password" {
  description = "Initial password for the Vault Userpass user bob."
  type        = string
  sensitive   = true
}
