# Prow job meta-definitions

This directory contains the meta-definitions for Prow jobs. These
meta-definitions are used by our [config-gen tool](../../config-gen/)
that is based off of [istio's
prowgen](https://github.com/istio/test-infra/tree/master/tools/prowgen).
The meta-definitions use the [prowgen job
syntax](https://github.com/istio/test-infra/tree/master/tools/prowgen#job-syntax).
The generated jobs from these meta-definitions are put into the
[../jobs/generated](../jobs/generated) directory. For more information
about Prow jobs in general please see [kubernetes Prow Jobs
documentation](https://github.com/kubernetes/test-infra/blob/master/prow/jobs.md).

## Summary of current directory

-   `.base.yaml` is the base configuration that has common logic for all
    the jobs.
-   `knative` contains the Prow jobs layed out for the most part per
    repo for the knative org.
-   `knative-sandbox` contains the Prow jobs layed out for the most part
    per repo for the knative-sandbox org.

## Notes on *-release-*.yaml files

There are `*-release-*.yaml` files that are auto generated for some
repos to track the release branches of those repos.
