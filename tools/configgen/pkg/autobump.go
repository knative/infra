/*
Copyright 2023 The Knative Authors

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

package pkg

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"
	prowgenpkg "istio.io/test-infra/tools/prowgen/pkg"
	"k8s.io/apimachinery/pkg/util/sets"
)

func GenerateAutobumpExclude(prowJobsConfigInput, autobumpConfigOutput string) error {

	excludedPrefixes := sets.NewString()

	bc := prowgenpkg.ReadBase(nil, filepath.Join(prowJobsConfigInput, ".base.yaml"))

	if err := filepath.WalkDir(prowJobsConfigInput, func(path string, d os.DirEntry, err error) error {
		log.Printf("Generating autobump excluded files for %q", path)
		// Skip directory, base config file and other unrelated files.
		if d.IsDir() || d.Name() == ".base.yaml" || !strings.HasSuffix(path, ".yaml") {
			return nil
		}

		baseConfig := bc
		if _, err := os.Stat(filepath.Join(filepath.Dir(path), ".base.yaml")); !os.IsNotExist(err) {
			baseConfig = prowgenpkg.ReadBase(&baseConfig, filepath.Join(filepath.Dir(path), ".base.yaml"))
		}
		cli := &prowgenpkg.Client{
			BaseConfig:          baseConfig,
			LongJobNamesAllowed: true,
		}

		jobsConfig := cli.ReadJobsConfig(path)

		prefixes := []string{
			fmt.Sprintf("prow/jobs_config/%s/%s-release", jobsConfig.Org, jobsConfig.Repo),
			fmt.Sprintf("prow/jobs/generated/%s/%s-release", jobsConfig.Org, jobsConfig.Repo),
		}

		excludedPrefixes.Insert(prefixes...)

		return nil
	}); err != nil {
		return fmt.Errorf("error walking dir %q: %w", prowJobsConfigInput, err)
	}

	if err := writeAutobumpExcludedFiles(excludedPrefixes.List(), autobumpConfigOutput); err != nil {
		return fmt.Errorf("error writing autobump config to %q: %w", autobumpConfigOutput, err)
	}

	return nil
}

func writeAutobumpExcludedFiles(prefixes []string, output string) error {
	log.Printf("writing autobump excluded prefix to %q: %v", output, prefixes)

	v := make([]interface{}, 0, len(prefixes))
	for _, p := range prefixes {
		v = append(v, p)
	}

	file, err := os.ReadFile(output)
	if err != nil {
		return fmt.Errorf("failed to read file %q: %w", output, err)
	}

	var node yaml.Node
	if err := yaml.NewDecoder(bytes.NewBuffer(file)).Decode(&node); err != nil {
		return fmt.Errorf("failed to decode file into node: %w", err)
	}

	_ = SetNestedField(&node, v, "excludedConfigPaths")

	buf := bytes.NewBuffer(nil)
	if err := yaml.NewEncoder(buf).Encode(&node); err != nil {
		return fmt.Errorf("failed to encode node into buf: %w", err)
	}

	if err := os.WriteFile(output, buf.Bytes(), 0600); err != nil {
		return fmt.Errorf("failed to write updates to %q: %w", output, err)
	}

	return nil
}

// SetNestedField sets YAML nested fields preserving comments.
func SetNestedField(node *yaml.Node, value interface{}, fields ...string) error {

	for i, n := range node.Content {

		if i > 0 && node.Content[i-1].Value == fields[0] {

			// Base case for scalar nodes
			if len(fields) == 1 && n.Kind == yaml.ScalarNode {
				n.SetString(fmt.Sprintf("%s", value))
				break
			}
			// base case for sequence node
			if len(fields) == 1 && n.Kind == yaml.SequenceNode {

				if v, ok := value.([]interface{}); ok {
					var s yaml.Node

					b, err := yaml.Marshal(v)
					if err != nil {
						return err
					}
					if err := yaml.NewDecoder(bytes.NewBuffer(b)).Decode(&s); err != nil {
						return err
					}

					n.Content = s.Content[0].Content
				}
				break
			}

			// Continue to the next level
			return SetNestedField(n, value, fields[1:]...)
		}

		if node.Kind == yaml.DocumentNode {
			return SetNestedField(n, value, fields...)
		}
	}

	return nil
}
