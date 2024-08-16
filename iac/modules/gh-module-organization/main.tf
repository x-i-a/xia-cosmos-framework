terraform {
  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

resource "github_repository" "foundation-repository" {
  for_each = local.all_foundations

  name        = each.value.repository
  description = "Foundation: ${each.value.name}"

  visibility = "public"

  template {
    owner                = local.template_owner
    repository           = local.template_repo
  }
}
