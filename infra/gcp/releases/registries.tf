# Migrated from Container Registry in February 2025. Keep the original hosts so
# historical release manifests continue to resolve without rewriting image URLs.
locals {
  gcr_locations = {
    "gcr.io"      = "us"
    "us.gcr.io"   = "us"
    "eu.gcr.io"   = "europe"
    "asia.gcr.io" = "asia"
  }
}

resource "google_artifact_registry_repository" "gcr" {
  for_each = local.gcr_locations

  project       = module.project.project_id
  location      = each.value
  repository_id = each.key
  description   = "Created by gcloud"
  format        = "DOCKER"

  # These repositories contain historical releases referenced by digest.
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_artifact_registry_repository_iam_member" "gcr_public" {
  for_each = google_artifact_registry_repository.gcr

  project    = each.value.project
  location   = each.value.location
  repository = each.value.name
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}

resource "google_artifact_registry_repository_iam_member" "gcr_publisher" {
  for_each = google_artifact_registry_repository.gcr

  project    = each.value.project
  location   = each.value.location
  repository = each.value.name
  role       = "roles/artifactregistry.repoAdmin"
  member     = "serviceAccount:${google_service_account.prow_job.email}"
}

# Preserve the Compute Engine service agent grants copied during migration.
resource "google_artifact_registry_repository_iam_member" "gcr_compute" {
  for_each = google_artifact_registry_repository.gcr

  project    = each.value.project
  location   = each.value.location
  repository = each.value.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:service-${module.project.project_number}@compute-system.iam.gserviceaccount.com"
}
