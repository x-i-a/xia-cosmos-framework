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
  structure = local.landscape["structure"]
}

locals {
  level_0_foundations = {
    for foundation, details in lookup(local.structure, "foundations", {}) : foundation => {
      name = foundation
      parent = "root"
    }
  }

  level_1_realms = {
    for realm, details in lookup(local.structure, "realms", {}) : realm => {
      name = realm
      parent = "root"
    }
  }

  level_1_foundations = {
    for idx, pair in flatten([
      for realm, details in lookup(local.structure, "realms", {}) : [
        for foundation, foundation_details in lookup(details, "foundations", {}) : {
          realm = realm
          foundation = foundation
        }
      ]
    ]) : "${pair.realm}/${pair.foundation}" => {
      parent = pair.realm
      name = pair.foundation
    }
  }

  level_2_realms = {
    for idx, pair in flatten([
      for realm, details in lookup(local.structure, "realms", {}) : [
        for sub_realm, sub_details in lookup(details, "realms", {}) : {
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
      for realm, details in lookup(local.structure, "realms", {}) : [
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
  all_foundations = merge(local.level_0_foundations, local.level_1_foundations)
}

data "google_organization" "cosmos_org" {
  domain = local.cosmos_org
}

resource "google_folder" "realm_folders" {
  for_each = local.all_realms
  display_name = each.value.name
  parent       = each.value.parent == "root" ? "organizations/${data.google_organization.cosmos_org.org_id}" : each.value.parent
}

resource "google_folder" "foundation_folders" {
  for_each = local.all_foundations
  display_name = each.value.name
  parent       = each.value.parent == "root" ? "organizations/${data.google_organization.cosmos_org.org_id}" : each.value.parent
}
