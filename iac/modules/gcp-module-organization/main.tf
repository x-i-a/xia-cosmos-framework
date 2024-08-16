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
  realms = local.landscape["structure"]["realms"]
}

locals {
  level_1_realms = {
    for realm, details in local.realms : realm => {
      name = realm
      parent = "root"
    }
  }

  level_2_realms = {
    for idx, pair in flatten([
      for realm, details in local.realms : [
        for sub_realm in keys(lookup(details, "realms", {})) : {
          realm = realm
          sub_realm = sub_realm
        }
      ]
    ]) : "${pair.realm}/${pair.sub_realm}" => {
      parent = pair.realm
      name = pair.sub_realm
    }
  }

  level_3_realms = {
    for idx, pair in flatten([
      for realm, details in local.realms : [
        for sub_realm, sub_details in lookup(details, "realms", {}) : [
          for bis_realm, bis_details in lookup(sub_details, "realms", {}) : {
            realm = realm
            sub_realm = sub_realm
            bis_realm = bis_realm
          }
        ]
      ]
    ]) : "${pair.realm}/${pair.sub_realm}/${pair.bis_realm}" => {
      parent = pair.sub_realm
      name = pair.bis_realm
    }
  }

  all_realms = merge(local.level_1_realms, local.level_2_realms, local.level_3_realms)
}

data "google_organization" "cosmos_org" {
  domain = local.cosmos_org
}

resource "google_folder" "realm_folders" {
  for_each = local.all_realms
  display_name = "TF Folder Test"
  parent       = each.value.parent == "root" ? "organizations/${data.google_organization.cosmos_org.org_id}" : each.value.parent
}
