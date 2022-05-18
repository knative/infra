# Prow

Prow is the tool we use that triggers jobs based on events and mangages
validation and other aspects of github. One can interact with it by
using a chat-ops `/slash` type commands via github comments. For more
infromation about Prow please see the [kubernetes Prow
documentation](https://github.com/kubernetes/test-infra/tree/master/prow)

## Summary of current directory

Within each directory there will be a `README.md` that will go in to
more details. Below is a summary:

-   `cluster-definitions` are the collection of deployment definitions
    for the different kubernetes clusters that are used by Prow.
-   `config` configurations for the different components of Prow.
-   `job-definitions` job definitions used by our slightly customized
    version of
    [prowgen](https://github.com/istio/test-infra/tree/master/tools/prowgen)
    config generation tool.
-   `jobs` are the actual job yaml that is either generated or
    hand-written that are used by Prow.
-   `Makefile` is an entry point to provide the initial deployment of
    the clusters explained in the cluster-definitions directory.

## Overview of Prow componets we use

### Core components

We use the merge automation and all the core components outlined in the
[kubernetes components
documentation](https://github.com/kubernetes/test-infra/blob/master/prow/cmd/README.md#core-components),
with the exeption of using the older
[plank](https://github.com/kubernetes/test-infra/tree/master/prow/plank)
instead of the
[prow-controller-manager](https://github.com/kubernetes/test-infra/blob/master/prow/cmd/prow-controller-manager).

### Other Components and Jobs

-   [`branchprotector`](https://github.com/kubernetes/test-infra/blob/master/prow/cmd/branchprotector)
    which configures [github branch
    protection](https://help.github.com/articles/about-protected-branches/)
    according to a specified policy.
-   [`generic-autobumper`](https://github.com/kubernetes/test-infra/blob/master/prow/cmd/generic-autobumper)
    which automates image version upgrades (e.g. for a Prow deployment)
    by opening a PR with images changed to their latest version
    according to a config file.
-   [`peribolos`](https://github.com/kubernetes/test-infra/blob/master/prow/cmd/peribolos)
    which manages GitHub org, team and membership settings according to
    a config file(s) (found in the [community
    repo](https://github.com/knative/community/tree/main/peribolos)).
-   [`label_sync`](https://github.com/kubernetes/test-infra/tree/master/label_sync)
    which updates or migratse github labels on repos in a github org
    based on a YAML file. Our YAML file is located in the [community
    repo](https://github.com/knative/community/tree/main/label_sync).

### Hook and it's plugins

[Hook](https://github.com/kubernetes/test-infra/blob/master/prow/cmd/hook)
is the most important piece. It is a stateless server that listens for
GitHub webhooks and dispatches them to the appropriate plugins. Hook's
plugins are used to trigger jobs, implement 'slash' commands, post to
Slack, and more. See the
[prow/plugins](https://github.com/kubernetes/test-infra/blob/master/prow/plugins)
directory for more information on plugins. The plugins we use can be
found in the [hook-plugins.yaml](config/hook-plugins.yaml) file.

## Simple Prow example

A simplified example is given below, for the more detailed example see
the [life of a Prow job
documentation](https://github.com/kubernetes/test-infra/blob/master/prow/life_of_a_prow_job.md):

1.  User types in `/test all` as a comment into a GitHub PR.
2.  GitHub sends a webhook (HTTP request) to Prow, to the
    `prow.k8s.io/hook` endpoint.
3.  The request gets intercepted by the \[ingress\]\[ingress-yaml\].
4.  The ingress routes the request to the **hook**
    \[service\]\[hook-service-yaml\].
5.  The **hook** component process that request by finding the
    corresponding component/plugin.
6.  In this case, the component/plugin is **trigger**. (The pattern is
    that **hook** constructs objects to be consumed by various plugins.)
7.  **trigger** determines which presubmit jobs to run (because it sees
    the `/test` command in `/test all`).
8.  **trigger** creates a ProwJob object!
9.  **prow-controller-manager** creates a pod to start the ProwJob.
10. When the ProwJob's pod finishes, **prow-controller-manager** updates
    the ProwJob.
11. **crier** sees the updated ProwJob status and reports back to the
    GitHub PR (creating a new comment).
12. **sinker** cleans up the old pod from above and deletes it from the
    Kubernetes API server.

The [cluster-definitions/](cluster-definitions/) directory has more
information about the different components/plugins and what they do. For
more info about what a Prow job is, the [jobs/](jobs/) directory will
have more information.
