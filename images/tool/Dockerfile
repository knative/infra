# Copyright 2020 The Knative Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.20.2

# Required input: -e TOOL_NAME=name, i.e. TOOL_NAME=flaky-test-reporter
ARG TOOL_NAME
# (Optional) Passed by automation, so we can inspect labels of built image.
ARG COMMIT_HASH
LABEL vcs-ref=$COMMIT_HASH \
      vcs-type="git" \
      vcs-url="https://github.com/knative/infra/blob/main/images/tool/Dockerfile"

RUN GOBIN=/tools go install "knative.dev/toolbox/${TOOL_NAME}@latest"

# Variable expansion isn't supported in ENTRYPOINT/CMD, so we need to
# create a symlink. See: https://stackoverflow.com/a/47643816/844449
RUN ln -s "/tools/${TOOL_NAME}" /bin/knative-tool

ENTRYPOINT ["/bin/knative-tool"]
