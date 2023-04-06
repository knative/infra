# README

`config/generator` is a tool for generating Prow and TestGrid config files for
Knative projects.

## Prow config generator

Prow config generator part is based on [istio prowgen](https://github.com/istio/test-infra/tree/master/tools/prowgen),
it does the following things:

1. Add annotations that can be used by [TestGrid
   configurator](https://github.com/kubernetes/test-infra/tree/master/testgrid/cmd/configurator)
   for generating TestGrid config file.

1. Calculate and add schedule for periodic Prow jobs to try to distribute the
   workloads evenly to avoid overloading Prow.

1. Use [istio
   prowgen](https://github.com/istio/test-infra/tree/master/tools/prowgen) to
   generate the Prow config files.

## TestGrid config generator

TestGrid config generator part generates the TestGrid config file that can be
used by
[TestGrid configurator](https://github.com/kubernetes/test-infra/tree/master/testgrid/cmd/configurator)
to configure [testgrid.knative.dev](https://testgrid.knative.dev)
