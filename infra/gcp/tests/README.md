# Knative Tests Project

Please be careful when making changes to infrastructure in this folder. Pay *extra* attention when modifying GKE Clusters as Prow runs on it.

Key Infrastructure:
- prow cluster
- prow build cluster
- prow trusted cluster

## TestGrid result notifications

Cloud Storage notifications on `gs://knative-prow` publish result-object changes
under `logs/` to `projects/knative-tests/topics/prow-updates`. The bucket
notification and topic already exist; `testgrid.tf` references the topic and
manages the `testgrid` subscription and its subscriber IAM permission.

The shared TestGrid updater runs in the `knative` namespace of the `auto` GKE
cluster in `k8s-testgrid` (`us-central1`). Its configuration lives in
[GoogleCloudPlatform/testgrid](https://github.com/GoogleCloudPlatform/testgrid/blob/main/cluster/prod/knative/updater.yaml)
and consumes `knative-tests/testgrid` as
`testgrid-updater@knative-tests.iam.gserviceaccount.com`.
Without this subscription, result ingestion falls back to hourly polling.
The subscription has auto-expiration disabled so updater inactivity does not
remove it.

