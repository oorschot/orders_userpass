resource "vault_auth_backend" "this" {
  type        = "userpass"
  path        = trim(var.path, "/")
  description = var.description

  tune {
    default_lease_ttl  = var.default_lease_ttl
    max_lease_ttl      = var.max_lease_ttl
    listing_visibility = var.listing_visibility
    token_type         = var.token_type
  }
}

resource "vault_userpass_auth_backend_user" "this" {
  for_each = nonsensitive(var.users)

  mount    = vault_auth_backend.this.path
  username = each.key

  password_wo         = var.users[each.key].password
  password_wo_version = 1

  token_policies                = var.users[each.key].token_policies
  token_ttl               = var.users[each.key].token_ttl
  token_max_ttl           = var.users[each.key].token_max_ttl
  token_no_default_policy = var.users[each.key].token_no_default_policy
  token_num_uses          = var.users[each.key].token_num_uses
  token_bound_cidrs       = var.users[each.key].token_bound_cidrs
}
