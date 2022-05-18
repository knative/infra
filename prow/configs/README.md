# Config

This directory contains the configuration files for the different
components of Prow as well as other tools that compliment the CI/CD
system. More information about Prow components can be found in the
[kubernetes prow/cmd/
directory](https://github.com/kubernetes/test-infra/blob/master/prow/cmd).

## Summary of current directory

-   `testgrid/` contains the configuration for the testgrid dashboard
    that shows the pass/fail of our tests. Currently the deployment
    itself is hosted by Google. The deployment yaml that Google is using
    is
    [here](https://github.com/GoogleCloudPlatform/testgrid/tree/master/cluster/prod/knative).
    For a more detailed overview see the [original testgrid
    repo](https://github.com/GoogleCloudPlatform/testgrid).
-   `config.yaml` is configuration file for the Prow componentsin our
    Prow deployment. Documentation for those components are located in
    the [kubernetes prow/cmd/
    directory](https://github.com/kubernetes/test-infra/blob/master/prow/cmd).
-   `plugins.yaml` contains the configuration for the different plugins
    for the Prow `hook` component. Hook is the component responcible for
    coordinating the Github events to the relevant Prow component. For
    more information on those plugins see the [kubernetes prow/plugins/
    directory](https://github.com/kubernetes/test-infra/tree/master/prow/plugins)
