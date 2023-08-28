# Based on https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs
module "gke-ingress-address" {
  source  = "terraform-google-modules/address/google"
  version = "~> 3.1"

  names  = [ "gke-ingress-ip"]
  global = true
}
