
We use argocd to sync cluster state with the configuration specified in knative/infra.

ArgoCD runs in the prow cluster and manages the following clusters:
- prow
- prow-build
- ~~prow-trusted~~


## Installation ownership

Argo CD itself is manually installed in the `prow` cluster using
`prow/cluster/gitops/bootstrap/kustomization.yaml`. The `apps` Application manages
application definitions, not the Argo CD installation. Merging a version update
therefore does not deploy it; an operator must apply the bootstrap manifests.
The upstream HA `cluster-install` base includes workloads, CRDs, and cluster RBAC.

## One-time bootstrap

Run from the repository root, with the `prow` context explicitly selected:

```sh
CONTEXT=gke_knative-tests_us-central1_prow
kubectl --context "$CONTEXT" create namespace argocd
kubectl --context "$CONTEXT" apply --server-side -n argocd -k prow/cluster/gitops/bootstrap
```

Then download the matching Argo CD CLI, select the `prow` context, and register
the managed clusters:

```sh
kubectl config use-context "$CONTEXT"
argocd login --core
argocd cluster add gke_knative-tests_us-central1_prow-build
argocd cluster add gke_knative-tests_us-central1_prow
kubectl --context "$CONTEXT" apply -f prow/cluster/gitops/bootstrap/apps.yaml
```

## Upgrades

1. Update the pinned release in `bootstrap/kustomization.yaml`. Read every
   intervening [upstream upgrade note](https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/overview/)
   and confirm Kubernetes compatibility for all managed clusters. For the upgrade
   from 2.9.2 to 3.6.1, rehearse intermediate 2.14 and 3.0 releases in a test
   environment before production; use patched releases, not 2.14.0.
2. Check the running image versions and application health. Securely back up Argo
   CD settings and credentials using the
   [disaster recovery guide](https://argo-cd.readthedocs.io/en/stable/operator-manual/disaster_recovery/),
   plus Application, ApplicationSet, and AppProject resources. Record the previous
   manifest revision and arrange a maintenance window.
3. Review live configuration that is not in Git, including repository and cluster
   secrets, RBAC, and Dex. This configuration preserves label-based tracking using
   `knative.dev/instance`; do not combine the upgrade with an annotation-tracking
   migration. Validate monitoring and External Secrets Helm rendering (3.6 uses
   Helm 4), the new resource exclusions, and image-registry access.
4. If pausing automatic sync, pause the parent `apps` Application first: its
   self-healing can otherwise restore automatic sync on child Applications. Record
   the original policies and restore them after verification.
5. Render and review the complete patched manifests, then dry-run against `prow`:

   ```sh
   CONTEXT=gke_knative-tests_us-central1_prow
   kubectl kustomize prow/cluster/gitops/bootstrap > /tmp/argocd-upgrade.yaml
   kubectl --context "$CONTEXT" diff --server-side -n argocd -f /tmp/argocd-upgrade.yaml
   kubectl --context "$CONTEXT" apply --server-side --dry-run=server -n argocd -f /tmp/argocd-upgrade.yaml
   ```

   `diff` exits with status 1 when there are differences. Review any field-ownership
   conflicts before proceeding. Upstream's upgrade procedure uses
   `--force-conflicts` to transfer ownership; this overwrites conflicting live
   customizations, so add any required customizations to the patches first. If
   needed, repeat the dry-run with that flag before using it in the actual apply.
6. Apply the reviewed output (adding `--force-conflicts` only after the review):

   ```sh
   kubectl --context "$CONTEXT" apply --server-side -n argocd -f /tmp/argocd-upgrade.yaml
   kubectl --context "$CONTEXT" -n argocd get deployments,statefulsets,pods
   kubectl --context "$CONTEXT" -n argocd rollout status deployment/argocd-server --timeout=5m
   kubectl --context "$CONTEXT" -n argocd rollout status deployment/argocd-repo-server --timeout=5m
   kubectl --context "$CONTEXT" -n argocd rollout status statefulset/argocd-application-controller --timeout=5m
   ```

   Use server-side apply: newer ApplicationSet CRDs exceed the client-side apply
   annotation size limit. Do not upgrade only container images or apply unpatched
   upstream manifests, which would bypass the Knative IAP and configuration patches.

   When upgrading from 2.9.2, Redis HA may stall during the authentication
   transition: the new pods reference `argocd-redis`, but remaining old pods lack
   the `AUTH` environment variable. If logs confirm authentication failures,
   restart the remaining old Redis pods so they pick up the new pod template.
   This installation uses `emptyDir` for Redis cache data; restarting these pods
   clears that cache, not the deployed applications. Verify the storage setup
   before using this recovery step on a different installation.
7. Verify all component rollouts, Redis HA health, IAP-protected UI access, Dex login,
   repository access, all managed clusters, and application diffs before resuming
   automatic sync. Update the CLI to match the server.

If verification fails, keep automatic sync paused and investigate before allowing
reconciliation. Reapplying the previous manifests does not necessarily undo CRD or
configuration changes; use the tested recovery plan and secure backup rather than
assuming an image downgrade is sufficient.


Couple of notes:
- Argo UI is accessible at https://argo.knative.dev, but it is restricted to the Google Groups that have IAP-secured Web App User on the knative-tests project.
