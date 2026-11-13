output "knative_infra_ingress_ip" {
  description = "Static IPv4 address used by the shared Knative infrastructure HTTPS Gateway."
  value       = google_compute_global_address.knative_infra_v4.address
}
