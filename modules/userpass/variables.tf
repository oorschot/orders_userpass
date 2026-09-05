variable "path" {
  description = <<-EOT
    Path at which to mount the Userpass auth method, without the auth/ prefix.

    Example:
      dev-team-userpass

    This creates:
      auth/dev-team-userpass/users/<username>
      auth/dev-team-userpass/login/<username>
  EOT

  type = string

  validation {
    condition     = length(trimspace(var.path, "/")) > 0
    error_message = "path must not be empty."
  }
}

variable "description" {
  description = "Human-readable description of the Userpass authentication mount."
  type        = string
  default     = "Userpass authentication managed by the platform team"
}

variable "default_lease_ttl" {
  description = "Default token TTL for this auth mount, for example 1h."
  type        = string
  default     = "1h"
}

variable "max_lease_ttl" {
  description = "Maximum token TTL for this auth mount, for example 8h."
  type        = string
  default     = "8h"
}

variable "listing_visibility" {
  description = "Whether the mount is displayed through unauthenticated Vault UI discovery endpoints."
  type        = string
  default     = "unauth"

  validation {
    condition     = contains(["unauth", "hidden"], var.listing_visibility)
    error_message = "listing_visibility must be either unauth or hidden."
  }
}

variable "token_type" {
  description = "Default token type issued by the auth mount."
  type        = string
  default     = "default-service"

  validation {
    condition = contains(
      ["default-service", "default-batch", "service", "batch"],
      var.token_type
    )

    error_message = "token_type must be default-service, default-batch, service, or batch."
  }
}

variable "users" {
  description = <<-EOT
    Map of Userpass users to create.

    The map key is the Vault username. Passwords should be injected as sensitive
    CI/CD or HCP Terraform variables, never committed to source control.

    Example:

    users = {
      alice = {
        password       = var.alice_password
        token_policies = ["orders-read"]
        token_ttl      = "1h"
        token_max_ttl  = "8h"
      }
    }
  EOT

  type = map(object({
    password                = string
    token_policies          = optional(list(string), [])
    token_ttl               = optional(string, "1h")
    token_max_ttl           = optional(string, "8h")
    token_no_default_policy = optional(bool, false)
    token_num_uses          = optional(number, 0)
    token_bound_cidrs       = optional(list(string), [])
  }))

  sensitive = true
  default   = {}

  validation {
    condition = alltrue([
      for username in keys(var.users) :
      length(trimspace(username)) > 0
    ])

    error_message = "Every username must contain at least one non-whitespace character."
  }
}
