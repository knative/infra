resource "google_folder" "boskos" {
  display_name = "Boskos"
  parent       = "organizations/22054930418"
}

locals {
  boskos_projects = [
    for i in range("01", "110") : format("knative-boskos-%02d", i)
  ]
}


module "project" {
  for_each = toset(local.boskos_projects)
  source   = "terraform-google-modules/project-factory/google"
  version  = "~> 12"

  name            = each.key
  project_id      = each.key
  folder_id       = google_folder.boskos.id
  org_id          = "22054930418"
  billing_account = "018CEF-0F96A6-4D1A14"

  # Sane project defaults
  default_service_account     = "keep"
  disable_services_on_destroy = false
  create_project_sa           = false
  random_project_id           = false


  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}


resource "google_artifact_registry_repository" "gcr" {
  for_each               = toset(local.boskos_projects)
  location               = "us"
  repository_id          = "gcr.io"
  format                 = "DOCKER"
  project                = module.project[each.key].project_id
  cleanup_policy_dry_run = false
  cleanup_policies {
    id     = "delete-images-older-than-7-days"
    action = "DELETE"
    condition {
      older_than = "604800s"
    }
  }
}

import {
  for_each = toset(local.boskos_projects)
  to       = module.project[each.key].module.project-factory.google_project.main
  id       = each.value
}
