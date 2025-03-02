# Generated by: tyk-ci/wf-gen
# Generated on: Fri Dec 17 15:34:44 UTC 2021

# Generation commands:
# ./pr.zsh -p -title sync for m4 templates -branch aws/pkr176 -base aws/pkr176 -repos tyk
# m4 -E -DxREPO=tyk


data "terraform_remote_state" "integration" {
  backend = "remote"

  config = {
    organization = "Tyk"
    workspaces = {
      name = "base-prod"
    }
  }
}

output "tyk" {
  value = data.terraform_remote_state.integration.outputs.tyk
  description = "ECR creds for tyk repo"
}

output "region" {
  value = data.terraform_remote_state.integration.outputs.region
  description = "Region in which the env is running"
}
