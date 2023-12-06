package test

import (
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type Name struct {
	Name string `json:"name"`
}

/**
 * Test AWS S3 bucket state file management
 */
func TestTerraformStateAWSS3Default(t *testing.T) {
	uniqueId := random.UniqueId()
	name := fmt.Sprintf("pmod%s", uniqueId)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"project": name,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputJSON := terraform.OutputJson(t, terraformOptions, "names")
	var names []Name
	err := json.Unmarshal([]byte(outputJSON), &names)
	if err != nil {
		t.Fatalf("Failed to unmarshal JSON output: %v", err)
	}

	if len(names) > 0 {
		expectedName := strings.ToLower(fmt.Sprintf("cs-%s-shared-uswest1-tfstate", name))
		assert.Equal(t, expectedName, names[0].Name)
	} else {
		t.Fatal("List of statefile storage container names are empty.")
	}
}
