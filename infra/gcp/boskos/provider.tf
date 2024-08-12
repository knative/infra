provider "google" {
}

provider "google-beta" {
}

terraform {
  required_version = "1.7.5"

  backend "gcs" {
    bucket = "knative-state"
    prefix = "boskos"
  }

  required_providers {
    google = {
      version = "5.39.0"
    }
    google-beta = {
      version = "5.39.0"
    }
  }
}
