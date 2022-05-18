# Knative Infra

Welcome to the home of the [Infra(Productivity) working
group](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md#productivity)!
This repo contains the configurations for the Knative infrastructure and
is the starting point to the many other repos we maintain, see the list
below. You can find us on the [Knative slack
\#productivity](https://slack.knative.dev/messages/productivity)
channel.

## Tools we use

### Github Actions

We use github actions for some automated tests, coordinating releases
and syncronizing files between repos. For general information about
github actions see github's [documentaion for
actions](https://docs.github.com/en/actions).

### TestGrid

Knative provides a health dashboard to show test, code and release
health for each repo. It covers key areas such as continuous
integration, nightly release, conformance and etc. The testgrid
dashboard is located at
[testgrid.knative.dev](https://testgrid.knative.dev/).

### E2E (end to end) Testing

Our E2E testing uses kubetest2 to build/deploy/test Knative clusters
(which are managed by Prow). For more information about kubenetes
kubetest2 see the [kubetest2
documentation](https://github.com/kubernetes-sigs/kubetest2).

### Prow

We use Prow to verify commits before they are merged, trigger tests,
handle the merge queue, trigger release builds, and much more. See the
[prow/](prow/) directory in this repo for more information. The
dashboard for prow is located at
[prow.knative.dev](https://prow.knative.dev/).

## Other repos we manage

-   [knative/.github](https://github.com/knative/.github) and
    [knative-sandbox/.github](https://github.com/knative-sandbox/.github)
    are used to sync certain files across repos such as our
    [CODE_OF_CONDUCT.md](https://github.com/knative/infra/blob/main/CODE_OF_CONDUCT.md)
    and other such files.

-   [knative/actions](https://github.com/knative/actions) contains
    reusable github workflows and actions.

-   [knative/hack](https://github.com/knative/hack) contains the shell
    scripts that are used across the repos.

-   [knative/release](https://github.com/knative/release) contains
    documentation and tools to aid in the Knative releases.

-   [knative-sandbox/actions-downstream-test](https://github.com/knative-sandbox/actions-downstream-test)
    contains a github action to test downstream repos upgradability from
    upstream repos.

-   [knative-sandbox/kperf](https://github.com/knative-sandbox/kperf)
    contains a performance test framework.

-   [knative-sandbox/knobots](https://github.com/knative-sandbox/knobots)
    which automates pull requests for routine maintenance tasks. Does
    this using github actions.
