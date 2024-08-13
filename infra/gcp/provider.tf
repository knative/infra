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
      version = "5.40.0"
    }
    google-beta = {
      version = "5.40.0"
    }
  }
}
