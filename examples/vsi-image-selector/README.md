# VSI image selector example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=common-utilities-vsi-image-selector-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-common-utilities/tree/main/examples/vsi-image-selector">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

This example shows how to get the latest image using the image-selector module. The region and API key are provided as inputs, and the module can optionally filter Ubuntu images by a specific release version such as `20`, `22`, or `24`.
