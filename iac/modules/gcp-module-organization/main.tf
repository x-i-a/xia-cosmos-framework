terraform {
  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

locals {
  landscape = yamldecode(file(var.landscape_file))
  settings = lookup(local.landscape, "settings", {})
  cosmos_org = local.settings["cosmos_org"]
  cosmos_project = local.settings["cosmos_project"]
  cosmos_name = local.settings["cosmos_name"]
  realms = local.settings["structure"]["realms"]
}

locals {
  level_1_realms = {
    for realm, details in local.realms : realm => {
      parent = "root"
    }
  }
  all_realms = merge(local.level_1_realms)
}

data "google_organization" "cosmos_org" {
  domain = local.cosmos_org
}

resource "google_folder" "realm_folders" {
  for_each = local.all_realms
  display_name = "TF Folder Test"
  parent       = each.value.parent == "root" ?
                 "organizations/${data.google_organization.cosmos_org.org_id}" :
                 each.value.parent
}
