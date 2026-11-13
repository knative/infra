# Migrate knative.dev redirects from App Engine

The shared `https-lb` Gateway serves infrastructure applications and the
`testgrid`, `slack`, `blog`, and `stats` redirects. Redirects are defined in
`prow/cluster/control-plane/redirects.yaml`; they require no backend service.
Both HTTP and HTTPS requests redirect to HTTPS destinations. The HTTP listener
only accepts routes from namespaces labeled `infra-redirect-access: "true"`,
so Grafana remains HTTPS-only.

The Gateway uses the global static address `knative-infra-ingress` in
`knative-tests`. Terraform passes this address from the tests module to the DNS
module, which uses it for Grafana and the four redirect domains. The existing
`knative-dev` certificate map supplies the wildcard HTTPS certificate.

## Deployment order

This change replaces the GCP address named `grafana-ingress`; it is not an
in-place rename. Expect a new IP and a Grafana maintenance window. Do not apply
the DNS changes before the Gateway is serving on the new address.

1. Review a Terraform plan with the repository's required Terraform version.
   Confirm that the old address is removed, the new address is created, and
   only Grafana and the four redirect domains change DNS routing.
2. Before merging the Gateway change (Argo CD automatically syncs `main`),
   provision the new address from this branch without changing DNS or deleting
   the old address. For this migration only, run a targeted plan/apply from
   `infra/gcp` for `module.tests.google_compute_global_address.knative_infra_v4`.
   Review the targeted plan before applying it; follow it with a full plan
   after the cutover.
3. Merge/sync the Gateway and redirect manifests. Wait for the Gateway to be
   programmed on the new IP and for all routes to be accepted with resolved
   references. If changing the Gateway address requires recreating the
   Gateway, coordinate that with Argo CD rather than deleting the Grafana
   workload.
4. Test Grafana and each redirect against the new IP before changing DNS:

   ```sh
   curl --resolve testgrid.knative.dev:443:NEW_IP \
     -D - -o /dev/null https://testgrid.knative.dev/
   curl --resolve testgrid.knative.dev:80:NEW_IP \
     -D - -o /dev/null http://testgrid.knative.dev/
   ```

   Also test the other hosts, non-root paths, and query strings. Confirm 302
   responses, destination paths, and the wildcard TLS certificate. Verify
   Grafana is healthy over HTTPS and is not exposed by the HTTP listener.
5. Once the old address has been detached from its load-balancer forwarding
   rules, review and apply the full Terraform plan. This changes the five DNS
   records and deletes the old reservation. Verify the public endpoints after
   DNS propagation (the records have a 300-second TTL).
6. Retire the old App Engine deployments only after verifying the cutover.

## App Engine cleanup

A read-only GCP inspection found that the four public custom-domain mappings
belong to the App Engine application in **`knative-tests`**. That application's
`testgrid` service sends 100% of traffic to Python 2.7 version
`20210407t215909`. There is also a duplicate redirect deployment in
**`knative-dns`**, with no custom-domain mappings.

Removing the source directory does not stop or delete either deployment.
After the DNS cutover is verified, inspect both applications for any remaining
users and retire the obsolete domain mappings, dispatch rules, services, and
versions. Account for the mandatory App Engine `default` service separately;
do not delete a GCP project or disable unrelated infrastructure as part of this
cleanup.

The new routes intentionally preserve the deployed stats destination,
`knative.teststats.cncf.io`, rather than the different destination previously
checked into the App Engine Makefile. The apex `knative.dev` website continues
to use Netlify; the old App Engine apex dispatch rule is not migrated.
