locals {
  landscape = yamldecode(file(var.landscape_file))
  settings = lookup(local.landscape, "settings", {})
  cosmos_org = local.settings["cosmos_org"]
  cosmos_project = local.settings["cosmos_project"]
  cosmos_name = local.settings["cosmos_name"]
  structure = local.landscape["structure"]
  github_owner = lookup(local.settings, "github_owner", "")
  template_owner = lookup(local.settings, "github_tpl_owner", "")
  template_repo = lookup(local.settings, "github_tpl_foundation", "")
}

locals {
  level_0_foundations = {
    for foundation, foundation_details in lookup(local.structure, "foundations", {}) : foundation => {
      name = foundation
      parent = "root"
      repository = lookup(foundation_details == null ?  {} : foundation_details, "repository", "foundation-${foundation}")
      template_owner =
    }
  }

  level_1_foundations = {
    for idx, pair in flatten([
      for realm, details in lookup(local.structure, "realms", {}) : [
        for foundation, foundation_details in lookup(details, "foundations", {}) : {
          realm = realm
          foundation = foundation
          repository = lookup(foundation_details == null ?  {} : foundation_details, "repository", "foundation-${foundation}")
        }
      ]
    ]) : "${pair.realm}/${pair.foundation}" => {
      parent = pair.realm
      name = pair.foundation
      repository = pair.repository
    }
  }

  level_2_foundations = {
    for idx, pair in flatten([
      for realm, details in lookup(local.structure, "realms", {}) : [
        for sub_realm, sub_details in lookup(details, "realms", {}) : [
          for foundation, foundation_details in lookup(sub_details, "foundations", {}) : {
            realm = realm
            sub_realm = sub_realm
            foundation = foundation
            repository = lookup(foundation_details == null ?  {} : foundation_details, "repository", "foundation-${foundation}")
          }
        ]
      ]
    ]) : "${pair.realm}/${pair.sub_realm}/${pair.foundation}" => {
      parent = "${pair.realm}/${pair.sub_realm}"
      name = pair.foundation
      repository = pair.repository
    }
  }

  level_3_foundations = {
    for idx, pair in flatten([
      for realm, details in lookup(local.structure, "realms", {}) : [
        for sub_realm, sub_details in lookup(details, "realms", {}) : [
          for bis_realm, bis_details in lookup(sub_details, "realms", {}) : [
            for foundation, foundation_details in lookup(bis_details, "foundations", {}) : {
              realm = realm
              sub_realm = sub_realm
              bis_realm = bis_realm
              foundation = foundation
              repository = lookup(foundation_details == null ?  {} : foundation_details, "repository", "foundation-${foundation}")
            }
          ]
        ]
      ]
    ]) : "${pair.realm}/${pair.sub_realm}/${pair.bis_realm}/${pair.foundation}" => {
      parent = "${pair.realm}/${pair.sub_realm}/${pair.bis_realm}"
      name = pair.foundation
      repository = pair.repository
    }
  }

  all_foundations = merge(local.level_0_foundations, local.level_1_foundations, local.level_2_foundations, local.level_3_foundations)
}
