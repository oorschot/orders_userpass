provider "vault" {
  address = var.vault_address

  ca_cert_file = var.vault_ca_cert_file

  # Do not put an admin Vault token in this file.
  #
  # For a local lab, export VAULT_TOKEN before Terraform runs:
  #
  # export VAULT_TOKEN="hvs...."
  #
  # In CI/CD, authenticate the Vault provider with a restricted automation
  # identity, such as JWT/OIDC, AppRole, cloud IAM, or a short-lived token.
}

resource "vault_policy" "orders_read" {
  name = "orders-read"

  policy = <<-HCL
    path "kv/data/apps/orders/*" {
      capabilities = ["read"]
    }

    path "kv/metadata/apps/orders/*" {
      capabilities = ["read", "list"]
    }
  HCL
}

module "orders_userpass" {
  source = "git::https://github.com/oorschot/orders_userpass.git//modules/userpass?ref=v1.0.0"
  path        = "orders_userpass"
  description = "Human Userpass access for the Orders development team"

  default_lease_ttl = "1h"
  max_lease_ttl     = "8h"
  listing_visibility = "unauth"
  token_type         = "default-service"

  users = {
    alice = {
      password       = var.alice_password
      token_policies = [vault_policy.orders_read.name]

      token_ttl      = "1h"
      token_max_ttl  = "8h"

      # Optional: restrict use to the corporate/VPN range.
      token_bound_cidrs = [
        "10.20.0.0/16"
      ]
    }

    bob = {
      password       = var.bob_password
      token_policies = [vault_policy.orders_read.name]
      token_ttl      = "1h"
      token_max_ttl  = "8h"
      token_bound_cidrs = [
        "10.20.0.0/16"
      ]
    }
  }
}

output "orders_userpass_login_path" {
  description = "Userpass login API path for the Orders team."
  value       = module.orders_userpass.login_path
}

output "orders_userpass_users" {
  description = "Userpass usernames managed for the Orders team."
  value       = module.orders_userpass.configured_usernames
}
