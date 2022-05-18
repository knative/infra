# Prow jobs

This directory contains Prow jobs used by Prow. The generated prow jobs
are made from the meta-definitions found in the
[../job-definitions/](../job-definitions/) directory. It is encouraged
to use that directory for any new jobs. There are handwritten jobs
located here as well however. For more information about Prow jobs in
general please see [kubernetes Prow Jobs
documentation](https://github.com/kubernetes/test-infra/blob/master/prow/jobs.md).

## Summary of current directory

-   `custom` directory contains handwritten Prow jobs. Please refrain
    from adding jobs here and add new jobs to the
    [../job-definitions/](../job-definitions/) directory.
-   `generated` contains the generated jobs from the meta-definitions
    defined in [../job-definitions/](../job-definitions/) directory.
-   `run_job.sh` is a useful convience script to run a job manually for
    testing purposes.
