provider "google" {
}

provider "google-beta" {
}

terraform {
  required_version = "1.7.5"

  backend "gcs" {
    bucket = "knative-state"
    prefix = "root"
  }

  required_providers {
    google = {
      version = "7.46.1"
    }
    google-beta = {
      version = "7.46.1"
    }
  }
}
