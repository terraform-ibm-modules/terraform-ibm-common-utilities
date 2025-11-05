// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"math/rand"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const crnParserExample = "examples/crn-parser"
const getImagesExample = "examples/image-selector"

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
		"region": validRegions[rand.Intn(len(validRegions))],
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
