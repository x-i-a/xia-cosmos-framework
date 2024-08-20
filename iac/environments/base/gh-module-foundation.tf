module "gh_module_foundation" {
  source = "../../modules/gh-module-foundation"

  module_name = "gh-module-foundation"
  config_file = "../../../config/core/github.yaml"
  landscape = local.landscape
  foundations = local.foundations
}
