# GCP K8s proof of concept with GPU nodes

This monorepo is a proof of concept of a Kubernetes cluster with a single GPU capable node which runs a Flask app with pytorch and cuda.

Prerequisites if you want to deploy things from your local machine

- Docker
- Terraform
- gcloud
- google-cloud-sdk-gke-gcloud-auth-plugin
- kubectl
- skaffold
- minikube, if you want to develop the model app locally and run it in a K8s like environment
