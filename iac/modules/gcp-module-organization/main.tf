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
  cosmos_name = local.settings["cosmos_name"]
}

data "google_organization" "my_org" {
  domain = "x-i-a.com"
}

resource "google_folder" "my_folder" {
  display_name = "TF Folder Test"
  parent       = "organizations/${data.google_organization.my_org.org_id}"
}