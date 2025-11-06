// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"math/rand"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const crnParserExample = "examples/crn-parser"
const getImagesExample = "examples/image-selector"

var validArchitectures = []string{"amd64", "s390x"}
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
		"region":       validRegions[rand.Intn(len(validRegions))],
		"architecture": validArchitectures[rand.Intn(len(validArchitectures))],
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
	if output != nil {
		// imageName := output["latest_image_name"]
		imageName := output.RawPlan.OutputChanges["latest_image_name"].After.(string)
		assert.Contains(t, imageName, "ubuntu", "Image name should include 'ubuntu'")

		// Check that image name contains either "amd64" or "s390x"
		isValidArch := strings.Contains(imageName, "amd64") || strings.Contains(imageName, "s390x")
		assert.True(t, isValidArch, "Image name should include either 'amd64' or 's390x'")
	}
}
