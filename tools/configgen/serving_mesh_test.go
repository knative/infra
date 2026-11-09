/*
Copyright 2026 The Knative Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"os"
	"testing"

	"sigs.k8s.io/yaml"
)

func TestServingMeshDiagnosticsScope(t *testing.T) {
	jobs := mustReadJobsConfig(t, jobsConfigPath+"/knative/serving.yaml")
	found := 0
	for _, job := range jobs.Jobs {
		target := job.Name == "istio-latest-mesh" && len(job.Types) == 1 && job.Types[0] == "periodic"
		flags := map[string]string{}
		for _, env := range job.Env {
			if env.Name == "MESH_DIAGNOSTICS" || env.Name == "ENABLE_GKE_TELEMETRY" {
				flags[env.Name] = env.Value
			}
		}
		if !target {
			if len(flags) > 0 {
				t.Fatalf("diagnostic flags leaked into job %s/%v", job.Name, job.Types)
			}
			continue
		}
		found++
		if job.Cron != "36 */6 * * *" {
			t.Fatalf("cron = %q, want four runs per day", job.Cron)
		}
		if flags["MESH_DIAGNOSTICS"] != "true" || flags["ENABLE_GKE_TELEMETRY"] != "true" {
			t.Fatal(flags)
		}
	}
	if found != 1 {
		t.Fatalf("found %d target periodic jobs", found)
	}
	// Check generated output too: presubmits must remain untouched.
	data, err := os.ReadFile("../../prow/jobs/generated/knative/serving-main.gen.yaml")
	if err != nil {
		t.Fatal(err)
	}
	type job struct {
		Name, Cron string
		Spec       struct {
			Containers []struct {
				Env []struct{ Name, Value string }
			}
		}
	}
	var generated struct {
		Periodics  []job
		Presubmits map[string][]job
	}
	if err := yaml.Unmarshal(data, &generated); err != nil {
		t.Fatal(err)
	}
	all := append([]job{}, generated.Periodics...)
	for _, jobs := range generated.Presubmits {
		all = append(all, jobs...)
	}
	count := 0
	for _, j := range all {
		for _, c := range j.Spec.Containers {
			for _, env := range c.Env {
				if env.Name != "MESH_DIAGNOSTICS" && env.Name != "ENABLE_GKE_TELEMETRY" {
					continue
				}
				if j.Name != "istio-latest-mesh_serving_main_periodic" || env.Value != "true" || j.Cron != "36 */6 * * *" {
					t.Fatalf("unexpected generated flag in %+v", j)
				}
				count++
			}
		}
	}
	if count != 2 {
		t.Fatalf("found %d generated flags, want 2", count)
	}
}
