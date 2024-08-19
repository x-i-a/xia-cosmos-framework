locals {
  landscape = yamldecode(file(var.landscape_file))
  settings = lookup(local.landscape, "settings", {})
  structure = local.landscape["structure"]
  modules = yamldecode(file(var.modules_file))
}

locals {
  level_0_foundations = {
    for foundation, foundation_details in lookup(local.structure, "foundations", {}) : foundation => {
      name = foundation
      parent = "root"
      repository_name = lookup(foundation_details == null ?  {} : foundation_details, "repository_name", "foundation-${foundation}")
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
          repository_name = lookup(foundation_details == null ?  {} : foundation_details, "repository_name", "foundation-${foundation}")
        }
      ]
    ]) : "${pair.realm}/${pair.foundation}" => {
      parent           = pair.realm
      name             = pair.foundation
      repository_name  = pair.repository_name
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

  level_2_foundations = {
    for idx, pair in flatten([
      for realm, details in lookup(local.structure, "realms", {}) : [
        for sub_realm, sub_details in lookup(details, "realms", {}) : [
          for foundation, foundation_details in lookup(sub_details, "foundations", {}) : {
            realm = realm
            sub_realm = sub_realm
            foundation = foundation
            repository_name = lookup(foundation_details == null ?  {} : foundation_details, "repository_name", "foundation-${foundation}")
          }
        ]
      ]
    ]) : "${pair.realm}/${pair.sub_realm}/${pair.foundation}" => {
      parent           = "${pair.realm}/${pair.sub_realm}"
      name             = pair.foundation
      repository_name  = pair.repository_name
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
      parent = "${pair.realm}/${pair.sub_realm}"
      name = pair.bis_realm
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
              repository_name = lookup(foundation_details == null ?  {} : foundation_details, "repository_name", "foundation-${foundation}")
            }
          ]
        ]
      ]
    ]) : "${pair.realm}/${pair.sub_realm}/${pair.bis_realm}/${pair.foundation}" => {
      parent          = "${pair.realm}/${pair.sub_realm}/${pair.bis_realm}"
      name            = pair.foundation
      repository_name = pair.repository_name
    }
  }

  all_realms = merge(local.level_1_realms, local.level_2_realms, local.level_3_realms)
  all_foundations = merge(local.level_0_foundations, local.level_1_foundations, local.level_2_foundations, local.level_3_foundations)
}
