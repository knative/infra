# Adopt the repositories and additive IAM grants created by the GCR migration.
# Import blocks are intentionally kept as a record of these existing resources.
locals {
  release_gcr_imports = {
    "gcr.io"      = "projects/knative-releases/locations/us/repositories/gcr.io"
    "us.gcr.io"   = "projects/knative-releases/locations/us/repositories/us.gcr.io"
    "eu.gcr.io"   = "projects/knative-releases/locations/europe/repositories/eu.gcr.io"
    "asia.gcr.io" = "projects/knative-releases/locations/asia/repositories/asia.gcr.io"
  }
  nightly_gcr_import = "projects/knative-nightly/locations/us/repositories/gcr.io"
}

import {
  for_each = local.release_gcr_imports
  to       = module.releases.google_artifact_registry_repository.gcr[each.key]
  id       = each.value
}

import {
  for_each = local.release_gcr_imports
  to       = module.releases.google_artifact_registry_repository_iam_member.gcr_public[each.key]
  id       = "${each.value} roles/artifactregistry.reader allUsers"
}

import {
  for_each = local.release_gcr_imports
  to       = module.releases.google_artifact_registry_repository_iam_member.gcr_publisher[each.key]
  id       = "${each.value} roles/artifactregistry.repoAdmin serviceAccount:prow-job@knative-releases.iam.gserviceaccount.com"
}

import {
  for_each = local.release_gcr_imports
  to       = module.releases.google_artifact_registry_repository_iam_member.gcr_compute[each.key]
  id       = "${each.value} roles/artifactregistry.writer serviceAccount:service-27694125260@compute-system.iam.gserviceaccount.com"
}

import {
  to = module.nightly.google_artifact_registry_repository.gcr
  id = local.nightly_gcr_import
}

import {
  to = module.nightly.google_artifact_registry_repository_iam_member.gcr_public
  id = "${local.nightly_gcr_import} roles/artifactregistry.reader allUsers"
}

import {
  to = module.nightly.google_artifact_registry_repository_iam_member.gcr_migration_admin
  id = "${local.nightly_gcr_import} roles/artifactregistry.repoAdmin user:cy@borg.dev"
}

import {
  to = module.nightly.google_artifact_registry_repository_iam_member.gcr_compute
  id = "${local.nightly_gcr_import} roles/artifactregistry.writer serviceAccount:service-543950810887@compute-system.iam.gserviceaccount.com"
}
