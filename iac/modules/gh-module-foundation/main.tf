terraform {
  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

locals {
  github_config = yamldecode(file(var.config_file))
}

resource "github_repository" "foundation-repository" {
  for_each = var.foundations

  name        = each.value["repository_name"]
  description = "Foundation: ${each.value["name"]}"

  visibility = each.value["visibility"]

  template {
    owner                = each.value["template_owner"]
    repository           = each.value["template_name"]
  }
}
