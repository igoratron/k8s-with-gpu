# Terraform

This terraform config will bring up a private GKE cluster, private Docker repo and a service account that can be used by Github Actions / other CI solution.

I've taken some shortcuts to prioritise getting everything up so there's more work I'd like to have done given more time. Things that haven't been done:
- preserving Terraform state in a remote backend (e.g. bucket)
- HTTPS
- DNS
- automating installing nvidia drivers, nginx-ingress and such
- putting all resources in the same region, mostly because it's hard to get hold of GPUs in GCP

### Creating the cluster
To create the cluster you'll at the very least need to:
- up the gpu quotas in GCP
- configure a billing account
- change some configuration in the `vars.tf` file

Once `terraform apply` runs successfully, you'll need to do the following
- authenticate with the cluster using `gcloud container clusters get-credentials`
- Install GPU drivers with `kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml`
- Install nginx-ingress with`kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml`
- either manually run `skaffold run` in the app directory, or kick off the github action

### Setting up the Github Action

In order for the Github action to work, you'll need to define `GCP_SERVICE_ACCOUNT_JSON` secret in Github action configuration. The base64 encoded JSON credentials are exported after `terraform apply` succeeds. To set them as a secret, you'll need to base64 decode them, minify them so that the JSON fits on a single line and then set them as a secret in Github UI.
