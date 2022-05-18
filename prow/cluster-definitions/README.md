# Cluster deployment definitions

This directory contains the definitions to deploy the following systems:

-   `Prow control plane cluster` is Prow, the Prow controller manager,
    and the different plugins/components for Prow. For more information
    of components please see the [kubernetes prow/cmd/
    directory](https://github.com/kubernetes/test-infra/blob/master/prow/cmd).
-   `Build cluster` is the cluster which runs the Prow jobs that are
    dispatched from the Prow controller manager hosted on the control
    plane cluster.
-   `Boskos pool` is a pool of GCP projects that are used to run end to
    end tests that need a cluster to deploy a full knative distribution.

## Summary of current directory

-   `build` has the definitions for the `Build cluster` outlined above.
-   `build/boskos-resources/boskos_resources.yaml` is the resources for
    the `Boskos pool` outlined above.
-   `core` has the definitions for the `Prow control plane cluster`
    outlined above.
-   `core/prowjob_customresourcedefinition.yaml` is the Prow job custom
    resource definition.
-   `monitoring` has the definitions for the monitoring the prow
    cluster. More information is contained in the `README.md` in this
    directory.

## Notes on cluster yaml convention

The folders that contain the different cluster definitions follow a
`###-*.yaml` convention. The yaml files are meant to be applied from
lowest to highest. An effort has been made to keep the yaml files as
small and easy to read as possible. This will be different from the
monolithic
[starter-\*.yaml](https://github.com/kubernetes/test-infra/tree/master/config/prow/cluster/starter)
file from the [Prow getting started
guide](https://github.com/kubernetes/test-infra/blob/master/prow/getting_started_deploy.md).
