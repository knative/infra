# The knative-prow bucket already publishes object notifications to this topic.
# Reference it without recreating the existing producer-side resources.
data "google_pubsub_topic" "prow_updates" {
  name    = "prow-updates"
  project = module.project.project_id
}

# Consumed by the shared TestGrid updater in the k8s-testgrid cluster's
# knative namespace via --subscribe=knative-prow=knative-tests/testgrid.
resource "google_pubsub_subscription" "testgrid" {
  name    = "testgrid"
  project = module.project.project_id
  topic   = data.google_pubsub_topic.prow_updates.id

  ack_deadline_seconds = 10

  # Keep the subscription even if the updater is inactive for an extended time.
  expiration_policy {
    ttl = ""
  }
}

resource "google_pubsub_subscription_iam_member" "testgrid_updater" {
  project      = google_pubsub_subscription.testgrid.project
  subscription = google_pubsub_subscription.testgrid.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.testgrid_updater.email}"
}
