module "cosign" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 4.2"

  project_id          = module.project.project_id
  purpose             = "ASYMMETRIC_SIGN"
  key_rotation_period = "" # 90 days
  key_algorithm       = "EC_SIGN_P384_SHA384"
  location            = "global"
  keyring             = "cosign"
  keys                = ["signing-key"]
}

module "cosign_iam" {
  source        = "terraform-google-modules/iam/google//modules/kms_key_rings_iam"
  version       = "~> 8.3"
  kms_key_rings = [module.cosign.keyring_resource.id]
  mode          = "authoritative"

  bindings = {
    "roles/cloudkms.signerVerifier" = [
      "serviceAccount:${google_service_account.prow_job.email}"
    ]
  }
}
