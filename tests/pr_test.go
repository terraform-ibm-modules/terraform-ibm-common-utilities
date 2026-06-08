// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const crnParserExample = "examples/crn-parser"
const getImagesExample = "examples/vsi-image-selector"
const icdVersionListerExample = "examples/icd-version-lister"
const icdFlavorSelectorExample = "examples/icd-flavor-selector"

var validRegions = []string{
	"us-south",
	"br-sao",
	"eu-de",
	"eu-gb",
	"eu-es",
	"jp-tok",
	"jp-osa",
	"au-syd",
	"ca-tor",
	"ca-mon",
	"us-east",
}

func setupOptions(t *testing.T, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
	})
	return options
}

func TestRunCRNParserExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, crnParserExample)
	options.TerraformVars = map[string]interface{}{
		"crn": "crn:version:cname:ctype:service-name:location:a/scope:service-instance:resource-type:resource",
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunSelectLatestImageExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, getImagesExample)
	options.TerraformVars = map[string]interface{}{
		"region":                   validRegions[common.CryptoIntn(len(validRegions))],
		"architecture":             "amd64",
		"operating_system":         "ubuntu",
		"operating_system_version": "24",
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	if output != nil {
		imageName := output.RawPlan.OutputChanges["latest_image_name"].After.(string)

		// Validate OS
		assert.Contains(t, imageName, "ubuntu", "Operating system should be 'ubuntu'")

		// Check that image name contains either "amd64" or "s390x"
		isValidArch := strings.Contains(imageName, "amd64")
		assert.True(t, isValidArch, "Image architecture should be 'amd64'")
	}
}

func testIcdVersionLister(t *testing.T, icd_type string) {

	options := setupOptions(t, icdVersionListerExample)
	options.TerraformVars = map[string]interface{}{
		"region":   "us-south",
		"icd_type": icd_type,
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	if output != nil {
		latestVersion := output.RawPlan.OutputChanges["latest_version"].After.(string)
		preferredVersion := output.RawPlan.OutputChanges["preferred_version"].After.(string)

		assert.NotEmpty(t, latestVersion, "latestVersion can't be empty")
		assert.NotEmpty(t, preferredVersion, "preferredVersion can't be empty")
	}
}

func TestIcdVersionLister(t *testing.T) {
	t.Parallel()

	icd_types := []string{"redis", "postgresql", "mysql", "rabbitmq", "mongodb", "elasticsearch"}

	for _, icd_type := range icd_types {
		t.Run(icd_type, func(t *testing.T) { testIcdVersionLister(t, icd_type) })
	}
}

func testIcdFlavorSelector(t *testing.T, icd_type string) {

	options := setupOptions(t, icdFlavorSelectorExample)
	options.TerraformVars = map[string]interface{}{
		"region":   "us-south",
		"icd_type": icd_type,
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	if output != nil {
		defaultFlavor := output.RawPlan.OutputChanges["default_flavor"].After.(string)
		availableFlavors := output.RawPlan.OutputChanges["available_flavors"].After.([]interface{})

		assert.NotEmpty(t, defaultFlavor, "defaultFlavor can't be empty")
		assert.NotEmpty(t, availableFlavors, "availableFlavors can't be empty")
		assert.Greater(t, len(availableFlavors), 0, "Should have at least one available flavor")

		// Verify default flavor is in the available flavors list
		flavorFound := false
		for _, flavor := range availableFlavors {
			if flavor.(string) == defaultFlavor {
				flavorFound = true
				break
			}
		}
		assert.True(t, flavorFound, "Default flavor should be in the available flavors list")
	}
}

func TestIcdFlavorSelector(t *testing.T) {
	t.Parallel()

	icd_types := []string{"postgresql", "mongodb"}

	for _, icd_type := range icd_types {
		t.Run(icd_type, func(t *testing.T) { testIcdFlavorSelector(t, icd_type) })
	}
}
