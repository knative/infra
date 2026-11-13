variable "billing_account" {
  type = string
}

variable "knative_infra_ingress_ip" {
  type        = string
  description = "Static IPv4 address used by the shared Knative infrastructure HTTPS Gateway."
}
