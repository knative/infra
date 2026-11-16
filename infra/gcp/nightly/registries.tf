# The gcr.io compatibility repository was created during migration in July 2024.
# The separate images repository below is retained at its existing address.
resource "google_artifact_registry_repository" "gcr" {
  project       = module.project.project_id
  location      = "us"
  repository_id = "gcr.io"
  description   = "Created by gcloud"
  format        = "DOCKER"

  # Preserve the existing nightly retention policy; release repositories have
  # no cleanup policy because historical release digests must remain available.
  cleanup_policies {
    id     = "delete-older-than-180-days"
    action = "DELETE"

    condition {
      tag_state  = "ANY"
      older_than = "15552000s"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_artifact_registry_repository_iam_member" "gcr_public" {
  project    = google_artifact_registry_repository.gcr.project
  location   = google_artifact_registry_repository.gcr.location
  repository = google_artifact_registry_repository.gcr.name
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}

# Preserve the existing migration operator's repository-level access. Prow's
# publishing access is already managed at project level in iam.tf.
resource "google_artifact_registry_repository_iam_member" "gcr_migration_admin" {
  project    = google_artifact_registry_repository.gcr.project
  location   = google_artifact_registry_repository.gcr.location
  repository = google_artifact_registry_repository.gcr.name
  role       = "roles/artifactregistry.repoAdmin"
  member     = "user:cy@borg.dev"
}

resource "google_artifact_registry_repository_iam_member" "gcr_compute" {
  project    = google_artifact_registry_repository.gcr.project
  location   = google_artifact_registry_repository.gcr.location
  repository = google_artifact_registry_repository.gcr.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:service-${module.project.project_number}@compute-system.iam.gserviceaccount.com"
}

resource "google_artifact_registry_repository" "images" {
  project       = module.project.project_id
  location      = "us"
  repository_id = "images"
  description   = "Nightly Knative Images"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "images" {
  project    = google_artifact_registry_repository.images.project
  location   = google_artifact_registry_repository.images.location
  repository = google_artifact_registry_repository.images.name
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}
